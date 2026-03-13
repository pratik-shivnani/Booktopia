# Booktopia Helper Agent

A Windows companion tool that analyzes your EPUB books using Ollama (local AI) and pushes character sheet & world area updates to the Booktopia Android app via a shared GitHub repo.

## Quick Start (Exe)

1. **Download** `booktopia-helper.exe` from [GitHub Releases](../../releases)
2. **Double-click** to launch — the interactive TUI opens automatically
3. Press **S** to open Settings, enter your GitHub PAT and Ollama details
4. Press **D** for Dashboard to see your synced books
5. Press **A** for Analyze, select a book, and click "Analyze New Chapters"

The exe is fully standalone — no Python install needed.

## Prerequisites

- **Ollama** running locally — [download here](https://ollama.com)
  ```
  ollama pull llama3.1
  ```
- A **private GitHub repo** (e.g. `booktopia-data`) with data pushed from the Android app
- A **GitHub PAT** with `repo` scope — [create one here](https://github.com/settings/tokens)

## Build From Source

If you prefer to build the exe yourself:

```bash
# Install Python 3.11+
pip install -r requirements.txt pyinstaller
pyinstaller --clean booktopia_helper.spec
# Output: dist/booktopia-helper.exe
```

Or on Windows, just double-click `build.bat`.

## Development

```bash
pip install -r requirements.txt

# Launch TUI (default)
python main.py

# CLI commands also available
python main.py status
python main.py analyze "Book Title"
python main.py config
python main.py update
```

Or double-click `run.bat` on Windows.

## Keyboard Shortcuts (TUI)

| Key | Action |
|-----|--------|
| `D` | Dashboard tab |
| `A` | Analyze tab |
| `S` | Settings tab |
| `R` | Refresh connections |
| `Q` | Quit |

## How It Works

```
┌─────────────┐    push data     ┌─────────────────┐    analyze     ┌─────────────┐
│  Booktopia   │ ──────────────→ │  GitHub Repo     │ ←──────────── │   Helper     │
│  Android App │ ←────────────── │  (booktopia-data)│ ──────────→── │   Agent      │
│              │   pull updates  │                  │  push updates │  + Ollama    │
└─────────────┘                  └─────────────────┘               └─────────────┘
```

1. Push your book data from the Android app (Cloud Sync settings)
2. The helper agent downloads the EPUB and runs it through Ollama
3. Extracted character sheets and world areas are pushed to `agent/pending_updates/`
4. The Android app picks up updates on next sync
