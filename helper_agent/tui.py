"""Booktopia Helper Agent — Textual TUI.

A rich interactive terminal UI for analyzing EPUBs with Ollama
and syncing updates to the Booktopia Android app via GitHub.
"""

from __future__ import annotations

import asyncio
from datetime import datetime
from functools import partial

from textual import work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Container, Horizontal, Vertical, VerticalScroll
from textual.screen import ModalScreen
from textual.widgets import (
    Button,
    DataTable,
    Footer,
    Header,
    Input,
    Label,
    ListItem,
    ListView,
    Log,
    ProgressBar,
    Rule,
    Static,
    Switch,
    TabbedContent,
    TabPane,
)

from logger import get_logger
from config_manager import load_config, save_config, get_github_config, get_ollama_config, load_state, save_state
from github_sync import GitHubSync
from epub_reader import parse_epub
from analyzer import BookAnalyzer, merge_analysis_results

__version__ = "0.1.0"
log = get_logger("booktopia.tui")


# ─── CSS ──────────────────────────────────────────────────────────────

CSS = """
Screen {
    background: $surface;
}

#status-bar {
    dock: top;
    height: 3;
    background: $primary-background;
    color: $text;
    padding: 0 2;
    layout: horizontal;
}

.status-item {
    width: 1fr;
    content-align: center middle;
}

.status-ok {
    color: $success;
}

.status-err {
    color: $error;
}

.status-warn {
    color: $warning;
}

.section-title {
    text-style: bold;
    padding: 1 0 0 0;
    color: $accent;
}

#book-table {
    height: 1fr;
}

#log-panel {
    height: 1fr;
    border: solid $primary;
}

.card {
    background: $panel;
    border: solid $primary;
    padding: 1 2;
    margin: 1 0;
}

.btn-row {
    layout: horizontal;
    height: auto;
    padding: 1 0;
}

.btn-row Button {
    margin: 0 1;
}

.form-field {
    margin: 0 0 1 0;
}

.form-label {
    padding: 0 0 0 0;
    color: $text-muted;
}

#analyze-progress {
    margin: 1 0;
}

#results-panel {
    height: 1fr;
    border: solid $accent;
}
"""


# ─── Main App ─────────────────────────────────────────────────────────

class BooktopiaAgent(App):
    """The Booktopia Helper Agent TUI."""

    TITLE = "Booktopia Helper Agent"
    SUB_TITLE = f"v{__version__}"
    CSS = CSS
    BINDINGS = [
        Binding("q", "quit", "Quit"),
        Binding("r", "refresh", "Refresh"),
        Binding("d", "show_tab('tab-dashboard')", "Dashboard", show=True),
        Binding("a", "show_tab('tab-analyze')", "Analyze", show=True),
        Binding("s", "show_tab('tab-settings')", "Settings", show=True),
    ]

    def __init__(self):
        super().__init__()
        self.config = load_config()
        self.books: list[dict] = []
        self.sync: GitHubSync | None = None
        self.analyzer: BookAnalyzer | None = None
        self._gh_ok = False
        self._ollama_ok = False

    def compose(self) -> ComposeResult:
        yield Header()
        yield Horizontal(
            Static("GitHub: ⏳ checking...", id="gh-status", classes="status-item"),
            Static("Ollama: ⏳ checking...", id="ollama-status", classes="status-item"),
            Static(f"Version: {__version__}", id="version-status", classes="status-item"),
            id="status-bar",
        )
        with TabbedContent(initial="tab-dashboard"):
            with TabPane("Dashboard", id="tab-dashboard"):
                yield DashboardPanel()
            with TabPane("Analyze", id="tab-analyze"):
                yield AnalyzePanel()
            with TabPane("Settings", id="tab-settings"):
                yield SettingsPanel()
        yield Footer()

    def on_mount(self) -> None:
        self.check_connections()

    @work(thread=True)
    def check_connections(self) -> None:
        """Test GitHub and Ollama connections in background."""
        gh_cfg = get_github_config(self.config)
        ol_cfg = get_ollama_config(self.config)

        # GitHub
        if gh_cfg.get("pat"):
            try:
                self.sync = GitHubSync(
                    pat=gh_cfg["pat"],
                    owner=gh_cfg["owner"],
                    data_repo=gh_cfg["data_repo"],
                    source_repo=gh_cfg.get("source_repo", "booktopia"),
                )
                ok, msg = self.sync.test_connection()
                self._gh_ok = ok
                self.call_from_thread(self._update_gh_status, ok, msg)
                if ok:
                    books = self.sync.list_books()
                    self.books = books
                    self.call_from_thread(self._populate_books, books)
            except Exception as e:
                self._gh_ok = False
                self.call_from_thread(self._update_gh_status, False, str(e))
        else:
            self._gh_ok = False
            self.call_from_thread(self._update_gh_status, False, "Not configured")

        # Ollama
        if ol_cfg.get("model"):
            try:
                self.analyzer = BookAnalyzer(model=ol_cfg["model"], host=ol_cfg["host"])
                ok, msg = self.analyzer.test_connection()
                self._ollama_ok = ok
                self.call_from_thread(self._update_ollama_status, ok, msg)
            except Exception as e:
                self._ollama_ok = False
                self.call_from_thread(self._update_ollama_status, False, str(e))
        else:
            self._ollama_ok = False
            self.call_from_thread(self._update_ollama_status, False, "Not configured")

    def _update_gh_status(self, ok: bool, msg: str) -> None:
        widget = self.query_one("#gh-status", Static)
        icon = "✓" if ok else "✗"
        cls = "status-ok" if ok else "status-err"
        widget.update(f"GitHub: {icon} {msg[:50]}")
        widget.set_classes(f"status-item {cls}")

    def _update_ollama_status(self, ok: bool, msg: str) -> None:
        widget = self.query_one("#ollama-status", Static)
        icon = "✓" if ok else "⚠"
        cls = "status-ok" if ok else "status-warn"
        widget.update(f"Ollama: {icon} {msg[:50]}")
        widget.set_classes(f"status-item {cls}")

    def _populate_books(self, books: list[dict]) -> None:
        try:
            dashboard = self.query_one(DashboardPanel)
            dashboard.populate_books(books)
            analyze = self.query_one(AnalyzePanel)
            analyze.populate_books(books)
        except Exception:
            pass

    def action_refresh(self) -> None:
        self.config = load_config()
        self.check_connections()

    def action_show_tab(self, tab_id: str) -> None:
        self.query_one(TabbedContent).active = tab_id


# ─── Dashboard Panel ──────────────────────────────────────────────────

class DashboardPanel(Static):
    """Shows synced books and pending updates."""

    def compose(self) -> ComposeResult:
        yield Label("Synced Books", classes="section-title")
        yield DataTable(id="book-table")
        yield Horizontal(
            Button("Refresh", id="btn-refresh", variant="default"),
            Button("Check Pending Updates", id="btn-pending", variant="primary"),
            classes="btn-row",
        )
        yield Label("", id="pending-label")

    def on_mount(self) -> None:
        table = self.query_one("#book-table", DataTable)
        table.add_columns("ID", "Title", "Author", "Last Analyzed")
        table.cursor_type = "row"

    def populate_books(self, books: list[dict]) -> None:
        table = self.query_one("#book-table", DataTable)
        table.clear()
        state = load_state()
        for book in books:
            book_id = str(book.get("id", "?"))
            book_state = state.get("books", {}).get(book_id, {})
            last_ch = book_state.get("last_chapter_analyzed")
            last_str = f"Ch. {last_ch}" if last_ch is not None else "—"
            table.add_row(
                book_id,
                book.get("title", "Untitled"),
                book.get("author", "Unknown"),
                last_str,
            )

    def on_button_pressed(self, event: Button.Pressed) -> None:
        app = self.app
        if not isinstance(app, BooktopiaAgent):
            return

        if event.button.id == "btn-refresh":
            app.action_refresh()
        elif event.button.id == "btn-pending":
            self._check_pending(app)

    @work(thread=True)
    def _check_pending(self, app: BooktopiaAgent) -> None:
        if not app.sync:
            self.call_from_thread(self._set_pending, "GitHub not connected")
            return
        pending = app.sync.list_pending_updates()
        msg = f"{len(pending)} pending update(s)" if pending else "No pending updates"
        self.call_from_thread(self._set_pending, msg)

    def _set_pending(self, msg: str) -> None:
        self.query_one("#pending-label", Label).update(msg)


# ─── Analyze Panel ────────────────────────────────────────────────────

class AnalyzePanel(Static):
    """Select a book and run Ollama analysis on its chapters."""

    def compose(self) -> ComposeResult:
        yield Label("Select a Book to Analyze", classes="section-title")
        yield DataTable(id="analyze-book-table")
        yield Horizontal(
            Button("Analyze New Chapters", id="btn-analyze-new", variant="success"),
            Button("Re-analyze All", id="btn-analyze-all", variant="warning"),
            classes="btn-row",
        )
        yield Label("", id="analyze-status")
        yield ProgressBar(id="analyze-progress", total=100, show_eta=False)
        yield Label("Analysis Log", classes="section-title")
        yield Log(id="log-panel", auto_scroll=True)

    def on_mount(self) -> None:
        table = self.query_one("#analyze-book-table", DataTable)
        table.add_columns("ID", "Title", "Author", "Chapters Analyzed")
        table.cursor_type = "row"
        self.query_one("#analyze-progress", ProgressBar).update(total=100, progress=0)

    def populate_books(self, books: list[dict]) -> None:
        table = self.query_one("#analyze-book-table", DataTable)
        table.clear()
        state = load_state()
        for book in books:
            book_id = str(book.get("id", "?"))
            book_state = state.get("books", {}).get(book_id, {})
            last_ch = book_state.get("last_chapter_analyzed")
            last_str = f"Up to Ch. {last_ch}" if last_ch is not None else "None yet"
            table.add_row(
                book_id,
                book.get("title", "Untitled"),
                book.get("author", "Unknown"),
                last_str,
            )

    def _get_selected_book(self) -> dict | None:
        app = self.app
        if not isinstance(app, BooktopiaAgent):
            return None
        table = self.query_one("#analyze-book-table", DataTable)
        if table.cursor_row is None:
            return None
        row = table.get_row_at(table.cursor_row)
        book_id = row[0]
        for b in app.books:
            if str(b.get("id", "")) == str(book_id):
                return b
        return None

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id in ("btn-analyze-new", "btn-analyze-all"):
            book = self._get_selected_book()
            if not book:
                self.query_one("#analyze-status", Label).update("Select a book first (use arrow keys)")
                return
            all_chapters = event.button.id == "btn-analyze-all"
            self._run_analysis(book, all_chapters)

    @work(thread=True)
    def _run_analysis(self, book: dict, all_chapters: bool) -> None:
        app = self.app
        if not isinstance(app, BooktopiaAgent):
            return

        log = self.query_one("#log-panel", Log)

        def log_msg(msg: str) -> None:
            self.call_from_thread(log.write_line, msg)

        def set_status(msg: str) -> None:
            self.call_from_thread(self.query_one("#analyze-status", Label).update, msg)

        def set_progress(pct: float) -> None:
            self.call_from_thread(
                self.query_one("#analyze-progress", ProgressBar).update,
                total=100,
                progress=pct,
            )

        book_id = book["id"]
        book_dir = book.get("_dir", str(book_id))
        title = book.get("title", "Untitled")

        set_status(f"Analyzing: {title}")
        log_msg(f"━━━ Starting analysis: {title} (ID: {book_id}) ━━━")

        if not app.sync:
            log_msg("ERROR: GitHub not connected")
            set_status("Error: GitHub not connected")
            return

        if not app.analyzer:
            log_msg("ERROR: Ollama not connected")
            set_status("Error: Ollama not connected")
            return

        # Download EPUB
        log_msg("Downloading EPUB...")
        set_progress(5)
        epub_path = app.sync.download_epub(book_id)
        if not epub_path:
            log_msg("ERROR: No EPUB found in data repo for this book")
            set_status("Error: No EPUB in repo — push it from the Android app first")
            return

        # Parse
        log_msg("Parsing EPUB...")
        set_progress(10)
        try:
            parsed = parse_epub(epub_path)
        except Exception as e:
            log_msg(f"ERROR parsing EPUB: {e}")
            set_status(f"Error: {e}")
            return

        log_msg(f"Found {parsed.total_chapters} chapters")

        # Determine chapters
        state = load_state()
        book_state = state.get("books", {}).get(str(book_id), {})
        last_analyzed = book_state.get("last_chapter_analyzed", -1)

        if all_chapters:
            chapters = parsed.chapters
        else:
            chapters = [ch for ch in parsed.chapters if ch.index > last_analyzed]

        if not chapters:
            log_msg("All chapters already analyzed! Use 'Re-analyze All' to redo.")
            set_status("Up to date — all chapters analyzed")
            set_progress(100)
            return

        log_msg(f"Analyzing {len(chapters)} chapter(s)...")

        # Analyze
        results = []
        for i, ch in enumerate(chapters):
            pct = 15 + (i / len(chapters)) * 75
            set_progress(pct)
            log_msg(f"  Ch.{ch.index}: {ch.title}...")

            try:
                result = app.analyzer.analyze_chapter(ch)
                results.append(result)

                if result.has_data():
                    parts = []
                    if result.character_sheets:
                        parts.append(f"{len(result.character_sheets)} sheet(s)")
                    if result.world_areas:
                        parts.append(f"{len(result.world_areas)} area(s)")
                    log_msg(f"    → Found: {', '.join(parts)}")
                else:
                    log_msg(f"    → No structured data found")
            except Exception as e:
                log_msg(f"    → Error: {e}")

        if not results:
            set_status("No results")
            set_progress(100)
            return

        # Merge
        merged = merge_analysis_results(results)
        sheets_total = len(merged.get("character_sheets", []))
        areas_total = len(merged.get("world_areas", []))

        log_msg(f"━━━ Results: {sheets_total} sheet(s), {areas_total} area(s) ━━━")

        if sheets_total:
            for sheet in merged["character_sheets"]:
                name = sheet.get("name", "?")
                level = sheet.get("level", "?")
                cls = sheet.get("className", "?")
                entries = len(sheet.get("entries", []))
                log_msg(f"  📋 {name} — Lv.{level} {cls} ({entries} stats)")

        if areas_total:
            for area in merged["world_areas"]:
                desc = area.get("description", "")
                if len(desc) > 60:
                    desc = desc[:60] + "..."
                log_msg(f"  🗺  {area.get('name', '?')}: {desc}")

        if not (sheets_total or areas_total):
            log_msg("No character stats or world areas found.")
            set_status("Analysis complete — nothing to push")
            set_progress(100)
            return

        # Push
        set_progress(92)
        log_msg("Pushing updates to GitHub...")
        try:
            app.sync.push_update(book_id, merged)
            log_msg("✓ Updates pushed! The Android app will pick them up on next sync.")

            # Save state
            if "books" not in state:
                state["books"] = {}
            state["books"][str(book_id)] = {
                "last_chapter_analyzed": merged.get("chapter_analyzed", last_analyzed),
            }
            save_state(state)

            set_status(f"Done! Pushed {sheets_total} sheet(s), {areas_total} area(s)")
            set_progress(100)

            # Refresh book table
            books = app.sync.list_books()
            app.books = books
            self.call_from_thread(app._populate_books, books)

        except Exception as e:
            log_msg(f"ERROR pushing: {e}")
            set_status(f"Push failed: {e}")


# ─── Settings Panel ───────────────────────────────────────────────────

class SettingsPanel(Static):
    """Configure GitHub and Ollama settings."""

    def compose(self) -> ComposeResult:
        yield Label("GitHub Configuration", classes="section-title")
        with Container(classes="card"):
            yield Label("Personal Access Token (repo scope)", classes="form-label")
            yield Input(id="input-pat", placeholder="ghp_...", password=True, classes="form-field")
            yield Label("GitHub Username / Owner", classes="form-label")
            yield Input(id="input-owner", placeholder="your-username", classes="form-field")
            yield Label("Data Repository Name", classes="form-label")
            yield Input(id="input-repo", placeholder="booktopia-data", classes="form-field")
            yield Label("Source Repository (for updates)", classes="form-label")
            yield Input(id="input-source", placeholder="booktopia", classes="form-field")

        yield Label("Ollama Configuration", classes="section-title")
        with Container(classes="card"):
            yield Label("Model Name", classes="form-label")
            yield Input(id="input-model", placeholder="llama3.1", classes="form-field")
            yield Label("Ollama Host URL", classes="form-label")
            yield Input(id="input-host", placeholder="http://localhost:11434", classes="form-field")

        yield Horizontal(
            Button("Save Settings", id="btn-save", variant="success"),
            Button("Test Connections", id="btn-test", variant="primary"),
            classes="btn-row",
        )
        yield Label("", id="settings-status")

    def on_mount(self) -> None:
        app = self.app
        if not isinstance(app, BooktopiaAgent):
            return
        config = app.config
        gh = get_github_config(config)
        ol = get_ollama_config(config)

        self.query_one("#input-pat", Input).value = gh.get("pat", "")
        self.query_one("#input-owner", Input).value = gh.get("owner", "")
        self.query_one("#input-repo", Input).value = gh.get("data_repo", "booktopia-data")
        self.query_one("#input-source", Input).value = gh.get("source_repo", "booktopia")
        self.query_one("#input-model", Input).value = ol.get("model", "llama3.1")
        self.query_one("#input-host", Input).value = ol.get("host", "http://localhost:11434")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn-save":
            self._save()
        elif event.button.id == "btn-test":
            self._save()
            app = self.app
            if isinstance(app, BooktopiaAgent):
                app.action_refresh()
                self.query_one("#settings-status", Label).update("Testing connections...")

    def _save(self) -> None:
        app = self.app
        if not isinstance(app, BooktopiaAgent):
            return

        config = {
            "github": {
                "pat": self.query_one("#input-pat", Input).value.strip(),
                "owner": self.query_one("#input-owner", Input).value.strip(),
                "data_repo": self.query_one("#input-repo", Input).value.strip(),
                "source_repo": self.query_one("#input-source", Input).value.strip(),
            },
            "ollama": {
                "model": self.query_one("#input-model", Input).value.strip(),
                "host": self.query_one("#input-host", Input).value.strip(),
            },
        }
        save_config(config)
        app.config = config
        self.query_one("#settings-status", Label).update("✓ Settings saved!")


# ─── Entry point ──────────────────────────────────────────────────────

def run_tui():
    """Launch the Textual TUI."""
    log.info("Creating BooktopiaAgent app instance")
    app = BooktopiaAgent()
    log.info("Calling app.run()")
    app.run()
    log.info("TUI exited normally")


if __name__ == "__main__":
    run_tui()
