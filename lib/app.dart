import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'ui/bookshelf/bookshelf_screen.dart';
import 'ui/book_detail/book_detail_screen.dart';
import 'ui/book_detail/add_edit_book_screen.dart';
import 'ui/characters/characters_screen.dart';
import 'ui/notes/notes_screen.dart';
import 'ui/world_areas/world_areas_screen.dart';
import 'ui/gallery/gallery_screen.dart';
import 'ui/mindmap/mindmap_screen.dart';
import 'ui/reader/epub_reader_screen.dart';
import 'ui/character_sheet/character_sheet_screen.dart';
import 'ui/mindmap/extraction_wizard.dart';
import 'ui/settings/sync_settings_screen.dart';
import 'ui/settings/moonreader_import_screen.dart';

CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOut).animate(animation)),
          child: child,
        ),
      );
    },
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'bookshelf',
      builder: (context, state) => const BookshelfScreen(),
    ),
    GoRoute(
      path: '/book/add',
      name: 'addBook',
      pageBuilder: (context, state) => _buildPage(const AddEditBookScreen(), state),
    ),
    GoRoute(
      path: '/book/:id',
      name: 'bookDetail',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(BookDetailScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/edit',
      name: 'editBook',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(AddEditBookScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/characters',
      name: 'characters',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(CharactersScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/notes',
      name: 'notes',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(NotesScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/world-areas',
      name: 'worldAreas',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(WorldAreasScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/gallery',
      name: 'gallery',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(GalleryScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/mindmap',
      name: 'mindmap',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(MindmapScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/reader',
      name: 'reader',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(EpubReaderScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/sheets',
      name: 'character_sheets',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(CharacterSheetScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/book/:id/extract',
      name: 'extraction_wizard',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildPage(ExtractionWizardScreen(bookId: id), state);
      },
    ),
    GoRoute(
      path: '/settings/sync',
      name: 'syncSettings',
      pageBuilder: (context, state) =>
          _buildPage(const SyncSettingsScreen(), state),
    ),
    GoRoute(
      path: '/settings/moonreader-import',
      name: 'moonreaderImport',
      pageBuilder: (context, state) =>
          _buildPage(const MoonReaderImportScreen(), state),
    ),
  ],
);

class BooktopiaApp extends StatelessWidget {
  const BooktopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Booktopia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
