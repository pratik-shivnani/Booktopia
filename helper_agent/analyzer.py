"""Ollama-powered analysis engine for extracting character stats and world areas."""

import json
import ollama
from typing import Optional

from epub_reader import EpubChapter


# ─── Prompt Templates ────────────────────────────────────────────────

SYSTEM_PROMPT = """You are a precise literary analysis assistant for LitRPG and fantasy novels.
You extract structured data from chapter text. Always respond with valid JSON only, no markdown, no explanation."""

CHARACTER_SHEET_PROMPT = """Analyze the following chapter text and extract ALL character stat blocks, skill updates, level changes, and class information.

For each character mentioned with stats, extract:
- name: The character's name
- level: Their current level (integer or null)
- className: Their class/job (string or null)
- entries: Array of stat entries, each with:
  - category: 0=core_stats, 1=skills, 2=resources, 3=abilities, 4=misc
  - key: The stat/skill name
  - value: The stat/skill value as a string

Look for:
- Stat blocks (STR, DEX, INT, WIS, CON, etc.)
- Skills with levels (e.g. "Dark Bolt Lv. 8")
- Resources (HP, MP, SP, Mana, Health, Stamina)
- Level ups and class changes
- New abilities or skill acquisitions
- Race, title, or other attributes

Chapter text:
---
{chapter_text}
---

Respond with JSON:
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
  ]
}}

If no character stats are found, return: {{"character_sheets": []}}"""

WORLD_AREA_PROMPT = """Analyze the following chapter text and extract all locations, areas, regions, cities, dungeons, or other named places.

For each location, extract:
- name: The location name
- description: A brief description based on context in the text (1-2 sentences)

Chapter text:
---
{chapter_text}
---

Respond with JSON:
{{
  "world_areas": [
    {{
      "name": "Ashenmoor",
      "description": "A cursed forest east of the capital, filled with undead creatures."
    }}
  ]
}}

If no locations are found, return: {{"world_areas": []}}"""

CHAPTER_SUMMARY_PROMPT = """Provide a brief 2-3 sentence summary of this chapter, focusing on:
- Key plot events
- Character developments
- Notable location changes

Chapter text:
---
{chapter_text}
---

Respond with JSON:
{{
  "summary": "Brief chapter summary here."
}}"""


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

        Args:
            chapter: The chapter to analyze.
            extract_sheets: Whether to extract character stat sheets.
            extract_areas: Whether to extract world areas.
            extract_summary: Whether to generate a chapter summary.

        Returns:
            AnalysisResult with extracted data.
        """
        # Truncate very long chapters to avoid context overflow
        text = chapter.plain_text
        if len(text) > 12000:
            text = text[:12000] + "\n\n[... text truncated for analysis ...]"

        sheets = []
        areas = []
        summary = ""

        if extract_sheets:
            sheets = self._extract_character_sheets(text)

        if extract_areas:
            areas = self._extract_world_areas(text)

        if extract_summary:
            summary = self._extract_summary(text)

        return AnalysisResult(
            chapter_index=chapter.index,
            chapter_title=chapter.title,
            character_sheets=sheets,
            world_areas=areas,
            summary=summary,
        )

    def _extract_character_sheets(self, text: str) -> list[dict]:
        """Extract character stat sheets from chapter text."""
        prompt = CHARACTER_SHEET_PROMPT.format(chapter_text=text)
        result = self._query_ollama(prompt)
        if result and "character_sheets" in result:
            return result["character_sheets"]
        return []

    def _extract_world_areas(self, text: str) -> list[dict]:
        """Extract world areas from chapter text."""
        prompt = WORLD_AREA_PROMPT.format(chapter_text=text)
        result = self._query_ollama(prompt)
        if result and "world_areas" in result:
            return result["world_areas"]
        return []

    def _extract_summary(self, text: str) -> str:
        """Generate a chapter summary."""
        prompt = CHAPTER_SUMMARY_PROMPT.format(chapter_text=text)
        result = self._query_ollama(prompt)
        if result and "summary" in result:
            return result["summary"]
        return ""

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
