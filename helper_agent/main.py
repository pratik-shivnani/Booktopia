"""Booktopia Helper Agent — CLI with Rich TUI.

A Windows companion tool that analyzes EPUB books using Ollama
and pushes character sheet / world area updates to the Booktopia
Android app via a shared GitHub repo.
"""

import sys
import argparse
from pathlib import Path

from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Prompt, Confirm
from rich import print as rprint

from config_manager import load_config, save_config, get_github_config, get_ollama_config, load_state, save_state
from github_sync import GitHubSync
from epub_reader import parse_epub
from analyzer import BookAnalyzer, merge_analysis_results

__version__ = "0.1.0"

console = Console()


# ─── Helpers ──────────────────────────────────────────────────────────

def _get_sync(config: dict) -> GitHubSync:
    gh = get_github_config(config)
    return GitHubSync(
        pat=gh["pat"],
        owner=gh["owner"],
        data_repo=gh["data_repo"],
        source_repo=gh.get("source_repo", "booktopia"),
    )


def _get_analyzer(config: dict) -> BookAnalyzer:
    ol = get_ollama_config(config)
    return BookAnalyzer(model=ol["model"], host=ol["host"])


def _find_book(books: list[dict], query: str) -> dict | None:
    """Find a book by title (case-insensitive partial match)."""
    query_lower = query.lower()
    for book in books:
        title = book.get("title", "").lower()
        if query_lower in title or title in query_lower:
            return book
    return None


# ─── Commands ─────────────────────────────────────────────────────────

def cmd_status(config: dict):
    """Show connection status and synced books."""
    console.print(Panel("[bold]Booktopia Helper Agent[/bold]", subtitle=f"v{__version__}"))

    # Test GitHub
    sync = _get_sync(config)
    with console.status("Testing GitHub connection..."):
        ok, msg = sync.test_connection()
    if ok:
        console.print(f"  [green]✓[/green] GitHub: {msg}")
    else:
        console.print(f"  [red]✗[/red] GitHub: {msg}")
        return

    # Test Ollama
    analyzer = _get_analyzer(config)
    with console.status("Testing Ollama connection..."):
        ok, msg = analyzer.test_connection()
    if ok:
        console.print(f"  [green]✓[/green] Ollama: {msg}")
    else:
        console.print(f"  [yellow]![/yellow] Ollama: {msg}")

    # List books
    console.print()
    with console.status("Fetching books..."):
        books = sync.list_books()

    if not books:
        console.print("  No books synced yet. Push data from the Android app first.")
        return

    state = load_state()

    table = Table(title="Synced Books")
    table.add_column("ID", style="dim")
    table.add_column("Title", style="bold")
    table.add_column("Author")
    table.add_column("Last Analyzed", justify="center")

    for book in books:
        book_id = str(book.get("id", "?"))
        book_state = state.get("books", {}).get(book_id, {})
        last_ch = book_state.get("last_chapter_analyzed")
        last_str = f"Ch. {last_ch}" if last_ch is not None else "[dim]—[/dim]"

        table.add_row(
            book_id,
            book.get("title", "Untitled"),
            book.get("author", "Unknown"),
            last_str,
        )

    console.print(table)

    # Pending updates
    pending = sync.list_pending_updates()
    if pending:
        console.print(f"\n  [yellow]{len(pending)} pending update(s)[/yellow] waiting for the Android app.")


def cmd_analyze(config: dict, book_query: str, chapter: int | None = None, all_chapters: bool = False):
    """Analyze a book's chapters using Ollama."""
    sync = _get_sync(config)
    analyzer = _get_analyzer(config)

    # Test Ollama first
    ok, msg = analyzer.test_connection()
    if not ok:
        console.print(f"[red]Ollama error:[/red] {msg}")
        return

    # Find the book
    with console.status("Fetching books..."):
        books = sync.list_books()

    book = _find_book(books, book_query)
    if not book:
        console.print(f"[red]Book not found:[/red] '{book_query}'")
        console.print("Available books:")
        for b in books:
            console.print(f"  • {b.get('title', 'Untitled')}")
        return

    book_id = book["id"]
    book_dir = book.get("_dir", str(book_id))
    console.print(f"[bold]Analyzing:[/bold] {book.get('title')} (ID: {book_id})")

    # Download EPUB
    with console.status("Downloading EPUB..."):
        epub_path = sync.download_epub(book_id)

    if not epub_path:
        console.print("[red]No EPUB found[/red] in the data repo for this book.")
        console.print("Make sure to push the EPUB from the Android app first.")
        return

    # Parse EPUB
    with console.status("Parsing EPUB..."):
        parsed = parse_epub(epub_path)

    console.print(f"  Found {parsed.total_chapters} chapters")

    # Determine which chapters to analyze
    state = load_state()
    book_state = state.get("books", {}).get(str(book_id), {})
    last_analyzed = book_state.get("last_chapter_analyzed", -1)

    if chapter is not None:
        chapters_to_analyze = [parsed.get_chapter(chapter)]
        if chapters_to_analyze[0] is None:
            console.print(f"[red]Chapter {chapter} not found[/red] (0-{parsed.total_chapters - 1})")
            return
    elif all_chapters:
        chapters_to_analyze = parsed.chapters
    else:
        # Analyze unprocessed chapters only
        chapters_to_analyze = [ch for ch in parsed.chapters if ch.index > last_analyzed]
        if not chapters_to_analyze:
            console.print("[green]All chapters already analyzed![/green] Use --all to re-analyze.")
            return

    console.print(f"  Analyzing {len(chapters_to_analyze)} chapter(s)...")

    # Analyze each chapter
    results = []
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("", total=len(chapters_to_analyze))

        for ch in chapters_to_analyze:
            progress.update(task, description=f"Analyzing: {ch.title}")
            result = analyzer.analyze_chapter(ch)
            results.append(result)

            if result.has_data():
                sheets_count = len(result.character_sheets)
                areas_count = len(result.world_areas)
                parts = []
                if sheets_count:
                    parts.append(f"{sheets_count} sheet(s)")
                if areas_count:
                    parts.append(f"{areas_count} area(s)")
                console.print(f"    Ch.{ch.index} [{ch.title}]: {', '.join(parts)}")

            progress.advance(task)

    if not results:
        console.print("[yellow]No data extracted.[/yellow]")
        return

    # Merge results
    merged = merge_analysis_results(results)
    sheets_total = len(merged.get("character_sheets", []))
    areas_total = len(merged.get("world_areas", []))

    console.print()
    console.print(f"  [bold]Results:[/bold] {sheets_total} character sheet(s), {areas_total} world area(s)")

    if not (sheets_total or areas_total):
        console.print("[yellow]No character stats or world areas found in these chapters.[/yellow]")
        return

    # Show preview
    if sheets_total:
        console.print("\n  [bold]Character Sheets:[/bold]")
        for sheet in merged["character_sheets"]:
            name = sheet.get("name", "?")
            level = sheet.get("level", "?")
            cls = sheet.get("className", "?")
            entries_count = len(sheet.get("entries", []))
            console.print(f"    • {name} — Lv.{level} {cls} ({entries_count} stats)")

    if areas_total:
        console.print("\n  [bold]World Areas:[/bold]")
        for area in merged["world_areas"]:
            console.print(f"    • {area.get('name', '?')}: {area.get('description', '')[:80]}")

    # Confirm push
    console.print()
    if Confirm.ask("Push these updates to GitHub?"):
        with console.status("Pushing updates..."):
            sync.push_update(book_id, merged)

        # Update state
        if "books" not in state:
            state["books"] = {}
        state["books"][str(book_id)] = {
            "last_chapter_analyzed": merged.get("chapter_analyzed", last_analyzed),
        }
        save_state(state)

        console.print("[green]✓ Updates pushed![/green] The Android app will pick them up on next sync.")
    else:
        console.print("[yellow]Skipped.[/yellow]")


def cmd_sync(config: dict):
    """Push any locally queued updates to GitHub."""
    console.print("[dim]All updates are pushed immediately after analysis.[/dim]")
    console.print("Use [bold]status[/bold] to check pending updates.")


def cmd_config_wizard(config: dict):
    """Interactive configuration wizard."""
    console.print(Panel("[bold]Configuration[/bold]"))

    gh = get_github_config(config)
    ol = get_ollama_config(config)

    gh["pat"] = Prompt.ask("GitHub PAT", default=gh.get("pat", ""))
    gh["owner"] = Prompt.ask("GitHub username", default=gh.get("owner", ""))
    gh["data_repo"] = Prompt.ask("Data repo name", default=gh.get("data_repo", "booktopia-data"))
    gh["source_repo"] = Prompt.ask("Source repo name (for updates)", default=gh.get("source_repo", "booktopia"))
    ol["model"] = Prompt.ask("Ollama model", default=ol.get("model", "llama3.1"))
    ol["host"] = Prompt.ask("Ollama host", default=ol.get("host", "http://localhost:11434"))

    config["github"] = gh
    config["ollama"] = ol
    save_config(config)
    console.print("[green]✓ Configuration saved![/green]")


def cmd_update(config: dict):
    """Check for and download the latest helper agent release."""
    sync = _get_sync(config)

    with console.status("Checking for updates..."):
        release = sync.get_latest_release()

    if not release:
        console.print("No helper agent releases found.")
        return

    remote_version = release["version"]
    console.print(f"  Current version: [bold]{__version__}[/bold]")
    console.print(f"  Latest version:  [bold]{remote_version}[/bold]")

    if remote_version <= __version__:
        console.print("[green]You're up to date![/green]")
        return

    console.print(f"\n  [yellow]Update available![/yellow] {release.get('name', '')}")
    if release.get("body"):
        console.print(f"  {release['body'][:200]}")

    if release.get("assets"):
        console.print("\n  Download the latest release from:")
        for asset in release["assets"]:
            console.print(f"    [link={asset['url']}]{asset['name']}[/link] ({asset['size'] // 1024}KB)")
    else:
        console.print("  No exe asset found in the release.")


# ─── Main ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Booktopia Helper Agent — Analyze EPUBs with Ollama",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # status
    subparsers.add_parser("status", help="Show connection status and synced books")

    # analyze
    analyze_parser = subparsers.add_parser("analyze", help="Analyze a book's chapters")
    analyze_parser.add_argument("book", help="Book title (partial match)")
    analyze_parser.add_argument("--chapter", "-c", type=int, help="Specific chapter index to analyze")
    analyze_parser.add_argument("--all", "-a", action="store_true", dest="all_chapters",
                                help="Re-analyze all chapters (not just new ones)")

    # sync
    subparsers.add_parser("sync", help="Check sync status")

    # config
    subparsers.add_parser("config", help="Configure GitHub and Ollama settings")

    # update
    subparsers.add_parser("update", help="Check for helper agent updates")

    # ui
    subparsers.add_parser("ui", help="Launch interactive TUI (default)")

    args = parser.parse_args()

    if not args.command:
        # Default to TUI when no command is given
        from tui import run_tui
        run_tui()
        return

    config = load_config()

    # Check if configured for commands that need it
    if args.command in ("status", "analyze", "sync", "update"):
        gh = get_github_config(config)
        if not gh.get("pat"):
            console.print("[yellow]Not configured yet.[/yellow] Run [bold]config[/bold] first.")
            cmd_config_wizard(config)
            config = load_config()

    if args.command == "ui":
        from tui import run_tui
        run_tui()
    elif args.command == "status":
        cmd_status(config)
    elif args.command == "analyze":
        cmd_analyze(config, args.book, chapter=args.chapter, all_chapters=args.all_chapters)
    elif args.command == "sync":
        cmd_sync(config)
    elif args.command == "config":
        cmd_config_wizard(config)
    elif args.command == "update":
        cmd_update(config)


if __name__ == "__main__":
    main()
