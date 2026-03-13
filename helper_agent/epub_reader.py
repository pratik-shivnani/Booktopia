"""EPUB parsing and chapter text extraction."""

import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
from pathlib import Path


class EpubChapter:
    """Represents a single chapter from an EPUB."""

    def __init__(self, index: int, title: str, html: str, plain_text: str):
        self.index = index
        self.title = title
        self.html = html
        self.plain_text = plain_text

    def __repr__(self):
        preview = self.plain_text[:80].replace("\n", " ")
        return f"Chapter({self.index}, '{self.title}', '{preview}...')"


class ParsedEpub:
    """Parsed EPUB with metadata and chapters."""

    def __init__(self, title: str, author: str, chapters: list[EpubChapter], path: str):
        self.title = title
        self.author = author
        self.chapters = chapters
        self.path = path

    @property
    def total_chapters(self) -> int:
        return len(self.chapters)

    def get_chapter(self, index: int) -> EpubChapter | None:
        if 0 <= index < len(self.chapters):
            return self.chapters[index]
        return None

    def get_chapters_range(self, start: int, end: int) -> list[EpubChapter]:
        return self.chapters[start:end]

    def __repr__(self):
        return f"ParsedEpub('{self.title}' by {self.author}, {self.total_chapters} chapters)"


def strip_html(html: str) -> str:
    """Convert HTML to plain text, preserving paragraph breaks."""
    soup = BeautifulSoup(html, "html.parser")

    # Remove script and style elements
    for tag in soup(["script", "style"]):
        tag.decompose()

    # Get text with paragraph separation
    text = soup.get_text(separator="\n")

    # Clean up whitespace
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped:
            lines.append(stripped)

    return "\n\n".join(lines)


def parse_epub(epub_path: str) -> ParsedEpub:
    """Parse an EPUB file and extract all chapters as plain text.

    Args:
        epub_path: Path to the .epub file.

    Returns:
        ParsedEpub with metadata and chapter list.
    """
    path = Path(epub_path)
    if not path.exists():
        raise FileNotFoundError(f"EPUB not found: {epub_path}")

    book = epub.read_epub(str(path))

    # Extract metadata
    title = "Untitled"
    title_meta = book.get_metadata("DC", "title")
    if title_meta:
        title = title_meta[0][0]

    author = "Unknown"
    creator_meta = book.get_metadata("DC", "creator")
    if creator_meta:
        author = creator_meta[0][0]

    # Extract chapters from spine (reading order)
    chapters = []
    chapter_index = 0

    for item in book.get_items_of_type(ebooklib.ITEM_DOCUMENT):
        html_content = item.get_content().decode("utf-8", errors="replace")
        plain_text = strip_html(html_content)

        # Skip very short items (likely navigation/title pages)
        if len(plain_text.strip()) < 100:
            continue

        # Try to extract chapter title from HTML
        soup = BeautifulSoup(html_content, "html.parser")
        chapter_title = _extract_chapter_title(soup, chapter_index)

        chapters.append(EpubChapter(
            index=chapter_index,
            title=chapter_title,
            html=html_content,
            plain_text=plain_text,
        ))
        chapter_index += 1

    return ParsedEpub(
        title=title,
        author=author,
        chapters=chapters,
        path=str(path),
    )


def _extract_chapter_title(soup: BeautifulSoup, fallback_index: int) -> str:
    """Try to extract a chapter title from HTML content."""
    # Try heading tags in order
    for tag in ["h1", "h2", "h3"]:
        heading = soup.find(tag)
        if heading:
            text = heading.get_text(strip=True)
            if text and len(text) < 200:
                return text

    # Try title tag
    title_tag = soup.find("title")
    if title_tag:
        text = title_tag.get_text(strip=True)
        if text and len(text) < 200:
            return text

    return f"Chapter {fallback_index + 1}"
