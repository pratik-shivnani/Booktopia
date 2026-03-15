"""Ollama-powered analysis engine for extracting character stats and world areas."""

import json
import re
import ollama
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional

from logger import get_logger
from epub_reader import EpubChapter

log = get_logger("booktopia.analyzer")

# Quick regex pre-filter: skip chapters that clearly have no game stats
_STAT_HINTS = re.compile(
    r'\b(?:'
    r'lv\.?|lvl\.?|level\s*\d|'
    r'str|dex|int|wis|con|cha|agi|vit|'
    r'hp|mp|sp|mana|health|stamina|'
    r'skill|ability|class:|race:|title:|'
    r'stat|attribute|\+\d+|\d+/\d+'
    r')\b',
    re.IGNORECASE,
)


# ─── Prompt Templates ────────────────────────────────────────────────

SYSTEM_PROMPT = """You are a precise literary analysis assistant for LitRPG and fantasy novels.
You extract structured data from chapter text. Always respond with valid JSON only, no markdown, no explanation."""

# Combined prompt — single LLM call per chapter instead of 3
COMBINED_PROMPT = """Extract the following from this chapter text:

1. CHARACTER STATS: Any stat blocks, skill updates, level changes, class info.
2. LOCATIONS: Named places, cities, dungeons, regions.
3. SUMMARY: 1-2 sentence chapter summary.

Chapter text:
---
{chapter_text}
---

Respond with JSON only:
{{
  "character_sheets": [
    {{
      "name": "CharacterName",
      "level": 47,
      "className": "Necromancer",
      "entries": [
        {{"category": 0, "key": "STR", "value": "45"}},
        {{"category": 1, "key": "Dark Bolt", "value": "Lv. 8"}},
        {{"category": 2, "key": "HP", "value": "1250/1250"}}
      ]
    }}
  ],
  "world_areas": [
    {{"name": "Ashenmoor", "description": "A cursed forest east of the capital."}}
  ],
  "summary": "Brief chapter summary."
}}

Categories: 0=core_stats, 1=skills, 2=resources, 3=abilities, 4=misc.
Return empty arrays if nothing found."""

# Lightweight prompt for chapters with no stat hints — skip character sheets
LIGHT_PROMPT = """Extract locations and a 1-sentence summary from this chapter.

Chapter text:
---
{chapter_text}
---

Respond with JSON only:
{{
  "world_areas": [
    {{"name": "PlaceName", "description": "Brief description."}}
  ],
  "summary": "Brief chapter summary."
}}

Return empty arrays if nothing found."""


# ─── Analyzer Class ──────────────────────────────────────────────────

class AnalysisResult:
    """Result of analyzing a single chapter."""

    def __init__(
        self,
        chapter_index: int,
        chapter_title: str,
        character_sheets: list[dict],
        world_areas: list[dict],
        summary: str = "",
    ):
        self.chapter_index = chapter_index
        self.chapter_title = chapter_title
        self.character_sheets = character_sheets
        self.world_areas = world_areas
        self.summary = summary

    def has_data(self) -> bool:
        return bool(self.character_sheets or self.world_areas)

    def to_dict(self) -> dict:
        return {
            "chapter_index": self.chapter_index,
            "chapter_title": self.chapter_title,
            "character_sheets": self.character_sheets,
            "world_areas": self.world_areas,
            "summary": self.summary,
        }


class BookAnalyzer:
    """Analyzes EPUB chapters using Ollama for intelligent extraction."""

    def __init__(self, model: str = "llama3.1", host: str = "http://localhost:11434"):
        self.model = model
        self.host = host
        self._client = ollama.Client(host=host)
        # Smaller models choke on long context — adapt truncation
        self._max_chapter_chars = 6000 if "3b" in model or "1b" in model else 12000
        log.info("Analyzer init: model=%s, max_chars=%d", model, self._max_chapter_chars)

    def test_connection(self) -> tuple[bool, str]:
        """Test connection to Ollama. Returns (success, message)."""
        try:
            models = self._client.list()
            model_names = [m.model for m in models.models]
            if not model_names:
                return False, "Ollama is running but no models are installed."

            # Check if configured model exists
            matching = [n for n in model_names if self.model in n]
            if matching:
                return True, f"Connected. Model '{self.model}' available."
            else:
                available = ", ".join(model_names[:5])
                return False, f"Model '{self.model}' not found. Available: {available}"
        except Exception as e:
            return False, f"Cannot connect to Ollama at {self.host}: {e}"

    def analyze_chapter(
        self,
        chapter: EpubChapter,
        extract_sheets: bool = True,
        extract_areas: bool = True,
        extract_summary: bool = True,
    ) -> AnalysisResult:
        """Analyze a single chapter for character stats and world areas.

        Uses a single combined LLM call. Pre-filters chapters without
        stat-like content to use a lighter prompt (skips sheet extraction).
        """
        text = chapter.plain_text

        # Truncate for smaller models — 6K chars ≈ 2K tokens
        max_chars = self._max_chapter_chars
        if len(text) > max_chars:
            text = text[:max_chars] + "\n\n[... truncated ...]"

        # Pre-filter: does this chapter likely contain game stats?
        has_stats = bool(_STAT_HINTS.search(text))

        if has_stats and extract_sheets:
            log.debug("Ch.%d '%s': full analysis (stat hints found)", chapter.index, chapter.title)
            prompt = COMBINED_PROMPT.format(chapter_text=text)
        else:
            log.debug("Ch.%d '%s': light analysis (no stat hints)", chapter.index, chapter.title)
            prompt = LIGHT_PROMPT.format(chapter_text=text)

        result = self._query_ollama(prompt)

        sheets = result.get("character_sheets", []) if result else []
        areas = result.get("world_areas", []) if result else []
        summary = result.get("summary", "") if result else ""

        return AnalysisResult(
            chapter_index=chapter.index,
            chapter_title=chapter.title,
            character_sheets=sheets,
            world_areas=areas,
            summary=summary,
        )

    def analyze_chapters_parallel(
        self,
        chapters: list[EpubChapter],
        max_workers: int = 2,
        on_result=None,
    ) -> list[AnalysisResult]:
        """Analyze multiple chapters concurrently.

        Args:
            chapters: Chapters to analyze.
            max_workers: Concurrent Ollama requests (2 is safe for most GPUs).
            on_result: Optional callback(AnalysisResult) for progress.

        Returns:
            List of AnalysisResult in chapter order.
        """
        results: dict[int, AnalysisResult] = {}
        log.info("Analyzing %d chapters with %d workers", len(chapters), max_workers)

        with ThreadPoolExecutor(max_workers=max_workers) as pool:
            futures = {
                pool.submit(self.analyze_chapter, ch): ch.index
                for ch in chapters
            }
            for future in as_completed(futures):
                idx = futures[future]
                try:
                    result = future.result()
                    results[idx] = result
                    if on_result:
                        on_result(result)
                except Exception as e:
                    log.error("Chapter %d failed: %s", idx, e)

        return [results[i] for i in sorted(results)]

    def _query_ollama(self, user_prompt: str) -> Optional[dict]:
        """Send a prompt to Ollama and parse JSON response."""
        try:
            response = self._client.chat(
                model=self.model,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_prompt},
                ],
                format="json",
                options={"temperature": 0.1},
            )

            content = response.message.content.strip()
            return json.loads(content)
        except json.JSONDecodeError:
            # Try to extract JSON from the response
            content = response.message.content.strip()
            start = content.find("{")
            end = content.rfind("}") + 1
            if start >= 0 and end > start:
                try:
                    return json.loads(content[start:end])
                except json.JSONDecodeError:
                    return None
            return None
        except Exception:
            return None


def merge_analysis_results(results: list[AnalysisResult]) -> dict:
    """Merge multiple chapter analysis results into a single update payload.

    Deduplicates character sheets (keeps latest values) and world areas (by name).
    """
    merged_sheets: dict[str, dict] = {}
    merged_areas: dict[str, dict] = {}
    max_chapter = 0

    for result in results:
        max_chapter = max(max_chapter, result.chapter_index)

        for sheet in result.character_sheets:
            name = sheet.get("name", "")
            if not name:
                continue

            if name in merged_sheets:
                existing = merged_sheets[name]
                # Update level/class if present
                if sheet.get("level") is not None:
                    existing["level"] = sheet["level"]
                if sheet.get("className"):
                    existing["className"] = sheet["className"]
                # Merge entries (upsert by key+category)
                existing_entries = {
                    (e["category"], e["key"]): e
                    for e in existing.get("entries", [])
                }
                for entry in sheet.get("entries", []):
                    existing_entries[(entry["category"], entry["key"])] = entry
                existing["entries"] = list(existing_entries.values())
            else:
                merged_sheets[name] = sheet.copy()

        for area in result.world_areas:
            name = area.get("name", "")
            if not name:
                continue
            if name not in merged_areas or area.get("description"):
                merged_areas[name] = area

    return {
        "character_sheets": list(merged_sheets.values()),
        "world_areas": list(merged_areas.values()),
        "chapter_analyzed": max_chapter,
    }
