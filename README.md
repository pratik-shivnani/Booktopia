# Booktopia

A cross-platform (Android + iOS) book tracker with interactive mindmap for characters, notes, and world-building.

## Features

- **Bookshelf** — Grid view of all books with cover images, status filters, search
- **Progress Tracking** — Page-level reading progress with visual progress bars
- **Characters** — Track characters per book with roles, descriptions, images
- **Notes** — Reading notes with optional page/chapter references
- **World Areas** — Locations and regions from the book's world
- **Image Gallery** — Fan art, maps, screenshots per book
- **Interactive Mindmap** — Drag-and-drop relationship graph between characters, world areas, and custom nodes
- **Moon+ Reader Pro Import** — Import books, progress, and highlights from Moon+ Reader backups

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Database | Drift (SQLite) |
| Image Loading | cached_network_image |
| Mindmap | CustomPaint + InteractiveViewer |

## Setup

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
│   ├── database/                # Drift tables, DAOs, database
│   └── repositories/            # Repository implementations
├── domain/models/               # Domain models
├── providers/                   # Riverpod providers
└── ui/
    ├── bookshelf/               # Home screen
    ├── book_detail/             # Book detail + add/edit
    ├── characters/              # (Phase 2)
    ├── notes/                   # (Phase 2)
    ├── world_areas/             # (Phase 2)
    ├── gallery/                 # (Phase 2)
    └── mindmap/                 # (Phase 3)
```
