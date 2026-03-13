# Booktopia

A cross-platform (Android + iOS) book tracker with interactive mindmap, EPUB reader, LitRPG character sheets, and AI-powered analysis via a Windows helper agent.

## Features

### Android App
- **Bookshelf** — Grid view with cover images, status filters, sorting, search, and continue-reading card
- **EPUB Reader** — Built-in reader with themes (light/dark/sepia), font settings, auto-scroll, bookmarks, and text highlighting with notes
- **Characters** — Track characters per book with roles, descriptions, images
- **LitRPG Character Sheets** — Auto-extract stat blocks (level, class, HP/MP/SP, skills) from EPUB text
- **Notes** — Reading notes with page/chapter references
- **World Areas** — Locations and regions from the book's world
- **Image Gallery** — Fan art, maps, screenshots per book
- **Interactive Mindmap** — Drag-and-drop relationship graph with auto-sync from reader (entity extraction + co-occurrence detection)
- **Extraction Wizard** — Heuristic NLP to discover characters and world areas from EPUB chapters
- **Cloud Sync** — Push/pull all data to a private GitHub repo (your "vault")
- **Moon+ Reader Pro Import** — Import books, progress, and highlights from Moon+ Reader backups
- **Self-Update** — Check for newer APK releases from GitHub

### Windows Helper Agent
- **Ollama Analysis** — Analyze EPUB chapters with a local LLM to extract character sheets and world areas
- **Interactive TUI** — Dashboard, Analyze, and Settings panels (Textual framework)
- **CLI Mode** — `status`, `analyze`, `config`, `update` commands
- **GitHub Sync** — Push analysis results as pending updates for the Android app to pick up
- **Standalone Exe** — PyInstaller build, no Python install required

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Database | Drift (SQLite) |
| EPUB Rendering | flutter_inappwebview |
| Secure Storage | flutter_secure_storage |
| Mindmap | CustomPaint + InteractiveViewer |
| Helper Agent | Python 3.11 + Textual + Ollama |
| CI/CD | GitHub Actions |

## Architecture

```
┌─────────────┐    push/pull     ┌─────────────────┐    analyze     ┌─────────────┐
│  Booktopia   │ ──────────────→ │  GitHub Repo     │ ←──────────── │   Helper     │
│  Android App │ ←────────────── │  (booktopia-data)│ ────────────→ │   Agent      │
│              │   pull updates  │                  │  push updates │  + Ollama    │
└─────────────┘                  └─────────────────┘               └─────────────┘
```

Both the app and helper agent communicate through a **private GitHub repo** (your "vault") using a single GitHub Personal Access Token (PAT).

## Setting Up the Vault (Cloud Sync)

### 1. Create the Private Repo

1. Go to [github.com/new](https://github.com/new)
2. Name it `booktopia-data` (or anything you like)
3. Set it to **Private**
4. **Do not** initialize with README/gitignore — leave it empty
5. Click "Create repository"

### 2. Create a Personal Access Token

1. Go to [GitHub Settings → Tokens](https://github.com/settings/tokens?type=beta) (Fine-grained tokens recommended)
2. Click "Generate new token"
3. Give it a name like `booktopia-sync`
4. Set expiration as needed
5. Under **Repository access**, select "Only select repositories" → pick your `booktopia-data` repo and optionally the `Booktopia` source repo (for self-update)
6. Under **Permissions → Repository permissions**, grant:
   - **Contents**: Read and write
   - **Metadata**: Read-only (auto-selected)
7. Click "Generate token" and **copy it immediately**

### 3. Configure the Android App

1. Open Booktopia → tap the **cloud icon** (☁) in the bookshelf app bar
2. Enter your **GitHub PAT**, **username**, and **repo name** (`booktopia-data`)
3. Tap **Test Connection** to verify
4. Tap **Push All** to upload your library
5. Optionally enable **Auto-sync on launch** to pull updates automatically

### 4. Configure the Helper Agent (Windows)

**Option A: Download the exe**
1. Download `booktopia-helper.exe` from [Releases](../../releases)
2. Double-click to launch the TUI
3. Press **S** → enter the same PAT, username, and repo name
4. Press **D** to see your synced books
5. Press **A** → select a book → "Analyze New Chapters"

**Option B: Run from source**
```bash
cd helper_agent
pip install -r requirements.txt
python main.py          # launches TUI
python main.py config   # or configure via CLI
```

### 5. Sync Workflow

1. **Push** data from the Android app (manual or auto-sync)
2. **Analyze** books with the helper agent (extracts character sheets + world areas via Ollama)
3. The agent pushes results to `agent/pending_updates/` in the vault
4. **Pull** from the Android app — agent updates are automatically applied and cleared

### Prerequisites for Helper Agent

- [Ollama](https://ollama.com) running locally with a model pulled:
  ```bash
  ollama pull llama3.1
  ```

## App Setup (Development)

This project uses [FVM](https://fvm.app/) for Flutter version management.

```bash
# Install FVM
brew tap leoafarias/fvm && brew install fvm

# Install Flutter SDK for this project
fvm install

# Get dependencies
fvm flutter pub get

# Run code generation (Drift)
fvm dart run build_runner build --delete-conflicting-outputs

# Run the app
fvm flutter run
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + GoRouter
├── theme/                       # Material 3 theme
├── data/
│   ├── database/                # Drift tables, DAOs, migrations
│   ├── repositories/            # Repository implementations
│   └── services/                # EpubService, SyncSerializer, GitHubSyncService, AppUpdateService
├── domain/models/               # Domain models
├── providers/                   # Riverpod providers
└── ui/
    ├── bookshelf/               # Home screen + continue reading
    ├── book_detail/             # Book detail + add/edit
    ├── reader/                  # EPUB reader + highlights + bookmarks
    ├── characters/              # Character management
    ├── character_sheet/         # LitRPG stat sheets
    ├── notes/                   # Reading notes
    ├── world_areas/             # World locations
    ├── gallery/                 # Image gallery
    ├── mindmap/                 # Interactive relationship graph
    ├── extraction_wizard/       # Heuristic entity extraction
    ├── settings/                # Sync settings + update check
    └── common/                  # Shared widgets

helper_agent/
├── main.py                      # CLI entry point (defaults to TUI)
├── tui.py                       # Textual interactive UI
├── epub_reader.py               # EPUB parsing + chapter extraction
├── analyzer.py                  # Ollama LLM analysis + prompt templates
├── github_sync.py               # GitHub API for data repo
├── config_manager.py            # YAML config + JSON state
├── booktopia_helper.spec        # PyInstaller build spec
├── build.bat                    # One-click Windows build
├── run.bat                      # One-click Windows launcher
└── requirements.txt             # Python dependencies
```

## CI/CD

| Workflow | Trigger | Output |
|---|---|---|
| `build.yml` | Push to `main` | Debug APK artifact |
| `build.yml` | Tag `v*` | Release APK → GitHub Releases |
| `build-helper.yml` | Push to `main` (helper_agent changes) | Helper exe artifact |
| `build-helper.yml` | Tag `helper-v*` | Helper exe → GitHub Releases |
