"""GitHub sync module for the Booktopia Helper Agent.

Reads book data from the shared GitHub data repo and writes
analysis results to agent/pending_updates/ for the Android app to pick up.
"""

import json
import base64
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from logger import get_logger
from github import Github, GithubException

log = get_logger("booktopia.github_sync")


class GitHubSync:
    """Handles all GitHub communication for the helper agent."""

    def __init__(self, pat: str, owner: str, data_repo: str, source_repo: str = "booktopia"):
        self._gh = Github(pat)
        self._owner = owner
        self._data_repo_name = data_repo
        self._source_repo_name = source_repo
        self._data_repo = None
        self._source_repo = None

    @property
    def data_repo(self):
        if self._data_repo is None:
            self._data_repo = self._gh.get_repo(f"{self._owner}/{self._data_repo_name}")
        return self._data_repo

    @property
    def source_repo(self):
        if self._source_repo is None:
            self._source_repo = self._gh.get_repo(f"{self._owner}/{self._source_repo_name}")
        return self._source_repo

    def test_connection(self) -> tuple[bool, str]:
        """Test connection to GitHub. Returns (success, message)."""
        try:
            user = self._gh.get_user()
            login = user.login
        except GithubException as e:
            return False, f"Authentication failed: {e.data.get('message', str(e))}"
        except Exception as e:
            return False, f"Connection failed: {e}"

        try:
            _ = self.data_repo.full_name
            return True, f"Connected as {login}. Data repo: {self._owner}/{self._data_repo_name}"
        except GithubException:
            return False, f"Authenticated as {login}, but repo '{self._owner}/{self._data_repo_name}' not found."

    # ─── Read operations ──────────────────────────────────────────────

    def list_books(self) -> list[dict]:
        """List all books in the data repo."""
        books = []
        try:
            contents = self.data_repo.get_contents("books")
            for item in contents:
                if item.type == "dir":
                    book_json = self._read_json(f"books/{item.name}/book.json")
                    if book_json:
                        book_json["_dir"] = item.name
                        books.append(book_json)
        except GithubException:
            pass
        return books

    def get_book_data(self, book_dir: str) -> Optional[dict]:
        """Read all data for a single book."""
        prefix = f"books/{book_dir}"
        book = self._read_json(f"{prefix}/book.json")
        if not book:
            return None

        return {
            "book": book,
            "characters": self._read_json(f"{prefix}/characters.json") or [],
            "world_areas": self._read_json(f"{prefix}/world_areas.json") or [],
            "character_sheets": self._read_json(f"{prefix}/character_sheets.json") or [],
            "notes": self._read_json(f"{prefix}/notes.json") or [],
        }

    def download_epub(self, book_id: int, dest_dir: str = None) -> Optional[str]:
        """Download an EPUB file from the repo.

        Args:
            book_id: The book ID to look for.
            dest_dir: Directory to save to. Uses temp dir if not specified.

        Returns:
            Path to the downloaded EPUB, or None if not found.
        """
        remote_path = f"epubs/book_{book_id}.epub"
        log.info("Downloading EPUB: %s", remote_path)

        try:
            file_content = self.data_repo.get_contents(remote_path)

            if dest_dir is None:
                dest_dir = tempfile.mkdtemp(prefix="booktopia_")
            dest_path = Path(dest_dir) / f"book_{book_id}.epub"

            # For files >1MB, GitHub Contents API returns content=None.
            # Use Git Blobs API as fallback (works for any size, private repos).
            if file_content.content:
                log.info("Decoding base64 content (%d chars)", len(file_content.content))
                epub_bytes = base64.b64decode(file_content.content)
            else:
                log.info("Content is None (file >1MB), using Git Blobs API (SHA: %s)", file_content.sha)
                blob = self.data_repo.get_git_blob(file_content.sha)
                epub_bytes = base64.b64decode(blob.content)

            log.info("Downloaded %d bytes, saving to %s", len(epub_bytes), dest_path)
            dest_path.write_bytes(epub_bytes)
            return str(dest_path)
        except GithubException as e:
            log.error("GitHub error downloading EPUB: %s", e)
            return None
        except Exception as e:
            log.error("Error downloading EPUB: %s", e)
            return None

    # ─── Write operations (pending updates) ───────────────────────────

    def push_update(self, book_id: int, update_data: dict) -> bool:
        """Push an analysis update to agent/pending_updates/.

        Args:
            book_id: The book this update is for.
            update_data: Dict with character_sheets, world_areas, etc.

        Returns:
            True on success.
        """
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        filename = f"agent/pending_updates/book_{book_id}_{timestamp}.json"

        payload = {
            "bookId": book_id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "source": "helper_agent",
            **update_data,
        }

        content = json.dumps(payload, indent=2, ensure_ascii=False)

        try:
            self.data_repo.create_file(
                path=filename,
                message=f"Agent update for book {book_id}",
                content=content,
            )
            return True
        except GithubException as e:
            raise RuntimeError(f"Failed to push update: {e.data.get('message', str(e))}")

    def list_pending_updates(self) -> list[str]:
        """List pending update files."""
        try:
            contents = self.data_repo.get_contents("agent/pending_updates")
            return [item.name for item in contents if item.name.endswith(".json")]
        except GithubException:
            return []

    # ─── Auto-update (check releases) ────────────────────────────────

    def get_latest_release(self) -> Optional[dict]:
        """Check for the latest helper agent release.

        Looks for releases with tags starting with 'helper-v'.
        """
        try:
            releases = self.source_repo.get_releases()
            for release in releases:
                if release.tag_name.startswith("helper-v"):
                    assets = []
                    for asset in release.get_assets():
                        if asset.name.endswith(".exe"):
                            assets.append({
                                "name": asset.name,
                                "url": asset.browser_download_url,
                                "size": asset.size,
                            })
                    return {
                        "tag": release.tag_name,
                        "version": release.tag_name.replace("helper-v", ""),
                        "name": release.title,
                        "body": release.body,
                        "assets": assets,
                        "published_at": release.published_at.isoformat(),
                    }
            return None
        except GithubException:
            return None

    # ─── Helpers ──────────────────────────────────────────────────────

    def _read_json(self, path: str) -> Optional[dict | list]:
        """Read and parse a JSON file from the repo."""
        try:
            file_content = self.data_repo.get_contents(path)
            decoded = base64.b64decode(file_content.content).decode("utf-8")
            return json.loads(decoded)
        except (GithubException, json.JSONDecodeError):
            return None

    def _ensure_directory(self, path: str):
        """Ensure a directory path exists in the repo (create .gitkeep if needed)."""
        try:
            self.data_repo.get_contents(path)
        except GithubException:
            try:
                self.data_repo.create_file(
                    path=f"{path}/.gitkeep",
                    message=f"Create {path} directory",
                    content="",
                )
            except GithubException:
                pass
