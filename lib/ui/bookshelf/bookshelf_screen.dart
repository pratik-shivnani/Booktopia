import 'dart:async';

import 'package:flutter/material.dart';

import '../common/platform_image.dart'
    if (dart.library.io) '../common/platform_image_native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/book.dart';
import '../../providers/providers.dart';

enum SortOption {
  titleAsc('Title A-Z'),
  titleDesc('Title Z-A'),
  authorAsc('Author A-Z'),
  ratingDesc('Rating ↓'),
  recentFirst('Recently Added');

  const SortOption(this.label);
  final String label;
}

final _selectedStatusProvider = StateProvider<BookStatus?>((ref) => null);
final _searchQueryProvider = StateProvider<String>((ref) => '');
final _sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.recentFirst);

class BookshelfScreen extends ConsumerStatefulWidget {
  const BookshelfScreen({super.key});

  @override
  ConsumerState<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends ConsumerState<BookshelfScreen> {
  bool _autoSyncDone = false;

  @override
  void initState() {
    super.initState();
    _tryAutoSync();
  }

  Future<void> _tryAutoSync() async {
    if (_autoSyncDone) return;
    _autoSyncDone = true;

    final syncService = ref.read(githubSyncServiceProvider);
    final configured = await syncService.isConfigured;
    if (!configured) return;

    final autoSync = await syncService.autoSyncEnabled;
    if (!autoSync) return;

    // Pull in background — don't block the UI
    try {
      final applied = await syncService.pullPendingAgentUpdates();
      if (applied > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied $applied update(s) from helper agent')),
        );
      }
    } catch (_) {
      // Silently fail — user can manually sync
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatus = ref.watch(_selectedStatusProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final sortOption = ref.watch(_sortOptionProvider);

    final booksAsync = searchQuery.isNotEmpty
        ? ref.watch(bookSearchProvider(searchQuery))
        : selectedStatus != null
            ? ref.watch(booksByStatusProvider(selectedStatus))
            : ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booktopia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            tooltip: 'Cloud Sync',
            onPressed: () => context.pushNamed('syncSettings'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'moonreader') {
                context.pushNamed('moonreaderImport');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'moonreader',
                child: Row(
                  children: [
                    Icon(Icons.import_export, size: 20),
                    SizedBox(width: 8),
                    Text('Import Moon+ Reader'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (v) => ref.read(_sortOptionProvider.notifier).state = v,
            itemBuilder: (_) => SortOption.values
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          if (s == sortOption)
                            Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(s.label),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _DebouncedSearchBar(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: _StatusFilterChips(selectedStatus: selectedStatus),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Continue Reading card
          const _ContinueReadingCard(),
          // Book grid
          Expanded(
            child: booksAsync.when(
              data: (books) {
                if (books.isEmpty) {
                  return _EmptyState(hasFilter: selectedStatus != null || searchQuery.isNotEmpty);
                }
                final sorted = _sortBooks(books, sortOption);
                return _BookGrid(books: sorted);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('addBook'),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }

  static List<Book> _sortBooks(List<Book> books, SortOption sort) {
    final sorted = List<Book>.from(books);
    switch (sort) {
      case SortOption.titleAsc:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortOption.titleDesc:
        sorted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      case SortOption.authorAsc:
        sorted.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
      case SortOption.ratingDesc:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case SortOption.recentFirst:
        sorted.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    }
    return sorted;
  }
}

class _StatusFilterChips extends ConsumerWidget {
  final BookStatus? selectedStatus;

  const _StatusFilterChips({required this.selectedStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: const Text('All'),
            selected: selectedStatus == null,
            onSelected: (_) {
              ref.read(_selectedStatusProvider.notifier).state = null;
            },
          ),
        ),
        ...BookStatus.values.map(
          (status) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status.label),
              selected: selectedStatus == status,
              onSelected: (_) {
                ref.read(_selectedStatusProvider.notifier).state =
                    selectedStatus == status ? null : status;
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DebouncedSearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends ConsumerState<_DebouncedSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Search books...',
      leading: const Icon(Icons.search),
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 350), () {
          ref.read(_searchQueryProvider.notifier).state = value;
        });
      },
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

class _BookGrid extends StatefulWidget {
  final List<Book> books;

  const _BookGrid({required this.books});

  @override
  State<_BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<_BookGrid> with TickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.books.length * 50),
    )..forward();
  }

  @override
  void didUpdateWidget(_BookGrid old) {
    super.didUpdateWidget(old);
    if (old.books.length != widget.books.length) {
      _staggerController.duration = Duration(milliseconds: 300 + widget.books.length * 50);
      _staggerController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final start = (index / widget.books.length).clamp(0.0, 1.0);
        final end = ((index + 1) / widget.books.length).clamp(0.0, 1.0);
        final animation = CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: _BookCard(book: widget.books[index]),
          ),
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => context.pushNamed('bookDetail', pathParameters: {'id': '${book.id}'}),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'book-cover-${book.id}',
                child: _BookCover(coverImagePath: book.coverImagePath),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (book.status == BookStatus.reading && book.totalPages > 0)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: book.progress,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(book.progress * 100).toInt()}%',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                    else
                      _StatusBadge(status: book.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String? coverImagePath;

  const _BookCover({this.coverImagePath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (fileExists(coverImagePath)) {
      return fileImageWidget(coverImagePath!, fit: BoxFit.cover);
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color fgColor;
    switch (status) {
      case BookStatus.reading:
        bgColor = colorScheme.primaryContainer;
        fgColor = colorScheme.onPrimaryContainer;
      case BookStatus.completed:
        bgColor = colorScheme.tertiaryContainer;
        fgColor = colorScheme.onTertiaryContainer;
      case BookStatus.wishlist:
        bgColor = colorScheme.secondaryContainer;
        fgColor = colorScheme.onSecondaryContainer;
      case BookStatus.dropped:
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastEpub = ref.watch(lastReadEpubProvider);

    return lastEpub.when(
      data: (epub) {
        if (epub == null) return const SizedBox.shrink();
        final bookAsync = ref.watch(bookByIdProvider(epub.bookId));
        return bookAsync.when(
          data: (book) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;
            final progress = book.totalPages > 0 ? book.progress : 0.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.pushNamed('reader', pathParameters: {'id': '${book.id}'}),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Book cover thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 44,
                            height: 62,
                            child: fileExists(book.coverImagePath)
                                ? fileImageWidget(book.coverImagePath!, fit: BoxFit.cover)
                                : Container(
                                    color: colorScheme.primaryContainer,
                                    child: Icon(Icons.menu_book, size: 24, color: colorScheme.primary),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Continue Reading',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                book.title,
                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                book.author,
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (progress > 0) ...[
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: progress,
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 4,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_filled, size: 32, color: colorScheme.primary),
                            if (progress > 0)
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({this.hasFilter = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter ? Icons.search_off_rounded : Icons.library_books_rounded,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'No books found' : 'Your bookshelf is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Try a different search or filter'
                : 'Tap + to add your first book',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}
