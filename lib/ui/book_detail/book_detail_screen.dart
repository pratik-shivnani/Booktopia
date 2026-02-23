import 'package:flutter/material.dart';

import '../common/platform_image.dart'
    if (dart.library.io) '../common/platform_image_native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/book.dart';
import '../../domain/models/epub_data.dart';
import '../../providers/providers.dart';

class BookDetailScreen extends ConsumerWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookByIdProvider(bookId));

    return bookAsync.when(
      data: (Book book) => _BookDetailContent(book: book),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BookDetailContent extends ConsumerWidget {
  final Book book;

  const _BookDetailContent({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final charCount = ref.watch(charactersByBookProvider(book.id!)).valueOrNull?.length;
    final noteCount = ref.watch(notesByBookProvider(book.id!)).valueOrNull?.length;
    final areaCount = ref.watch(worldAreasByBookProvider(book.id!)).valueOrNull?.length;
    final imageCount = ref.watch(imagesByBookProvider(book.id!)).valueOrNull?.length;
    final nodeCount = ref.watch(mindmapNodesByBookProvider(book.id!)).valueOrNull?.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.pushNamed(
                  'editBook',
                  pathParameters: {'id': '${book.id}'},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'book-cover-${book.id}',
                child: _BookHeader(book: book),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title & Author
                Text(book.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(book.author, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),

                // Genre & Rating row
                Row(
                  children: [
                    if (book.genre != null) ...[
                      Chip(
                        label: Text(book.genre!),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (book.rating != null) ...[
                      ...List.generate(
                        book.rating!.toInt(),
                        (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Progress section
                _ProgressSection(book: book),
                const SizedBox(height: 24),

                // Quick access sections
                _SectionCard(
                  icon: Icons.people_outline,
                  title: 'Characters',
                  subtitle: 'Track characters in this book',
                  count: charCount,
                  onTap: () => context.pushNamed('characters', pathParameters: {'id': '${book.id}'}),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.note_alt_outlined,
                  title: 'Notes',
                  subtitle: 'Your reading notes and highlights',
                  count: noteCount,
                  onTap: () => context.pushNamed('notes', pathParameters: {'id': '${book.id}'}),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.public,
                  title: 'World Areas',
                  subtitle: 'Locations and regions',
                  count: areaCount,
                  onTap: () => context.pushNamed('worldAreas', pathParameters: {'id': '${book.id}'}),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.photo_library_outlined,
                  title: 'Images',
                  subtitle: 'Fan art, maps, and screenshots',
                  count: imageCount,
                  onTap: () => context.pushNamed('gallery', pathParameters: {'id': '${book.id}'}),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.hub_outlined,
                  title: 'Mindmap',
                  subtitle: 'Character relationships and connections',
                  count: nodeCount,
                  onTap: () => context.pushNamed('mindmap', pathParameters: {'id': '${book.id}'}),
                ),
                const SizedBox(height: 12),
                _EpubReaderCard(book: book),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(bookRepositoryProvider).deleteBook(book.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${book.title}" deleted')),
                );
                context.pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BookHeader extends StatelessWidget {
  final Book book;

  const _BookHeader({required this.book});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (fileExists(book.coverImagePath)) {
      return Stack(
        fit: StackFit.expand,
        children: [
          fileImageWidget(book.coverImagePath!, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  colorScheme.surface.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 80,
          color: colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _ProgressSection extends ConsumerWidget {
  final Book book;

  const _ProgressSection({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reading Progress', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                _StatusChip(status: book.status),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: book.progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${book.currentPage} of ${book.totalPages}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  '${(book.progress * 100).toInt()}%',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _QuickUpdateRow(book: book),
          ],
        ),
      ),
    );
  }
}

class _QuickUpdateRow extends ConsumerStatefulWidget {
  final Book book;

  const _QuickUpdateRow({required this.book});

  @override
  ConsumerState<_QuickUpdateRow> createState() => _QuickUpdateRowState();
}

class _QuickUpdateRowState extends ConsumerState<_QuickUpdateRow> {
  final _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _pageController,
            decoration: InputDecoration(
              hintText: 'Update page...',
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.check, size: 20),
                onPressed: _updatePage,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _updatePage(),
          ),
        ),
      ],
    );
  }

  void _updatePage() {
    final page = int.tryParse(_pageController.text);
    if (page == null) return;

    final clamped = page.clamp(0, widget.book.totalPages);
    final isComplete = clamped >= widget.book.totalPages;
    final updated = widget.book.copyWith(
      currentPage: clamped,
      status: isComplete ? BookStatus.completed : widget.book.status,
      dateFinished: isComplete ? DateTime.now() : widget.book.dateFinished,
    );

    ref.read(bookRepositoryProvider).updateBook(updated);
    _pageController.clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isComplete
              ? 'Congratulations! Book completed!'
              : 'Progress updated to page $clamped'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final BookStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color color;
    switch (status) {
      case BookStatus.reading:
        icon = Icons.auto_stories;
        color = colorScheme.primary;
      case BookStatus.completed:
        icon = Icons.check_circle;
        color = colorScheme.tertiary;
      case BookStatus.wishlist:
        icon = Icons.bookmark_border;
        color = colorScheme.secondary;
      case BookStatus.dropped:
        icon = Icons.cancel_outlined;
        color = colorScheme.error;
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(status.label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}

class _EpubReaderCard extends ConsumerWidget {
  final Book book;

  const _EpubReaderCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final epubAsync = ref.watch(epubByBookProvider(book.id!));

    return epubAsync.when(
      data: (epubData) {
        final hasEpub = epubData != null;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: hasEpub
                  ? colorScheme.tertiaryContainer
                  : colorScheme.primaryContainer,
              child: Icon(
                hasEpub ? Icons.auto_stories : Icons.upload_file,
                color: hasEpub
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(hasEpub ? 'Read EPUB' : 'Import EPUB'),
            subtitle: Text(hasEpub
                ? 'Continue reading · Ch. ${epubData.currentChapterIndex + 1}'
                : 'Import an EPUB file to read in-app'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasEpub)
                  IconButton(
                    icon: Icon(Icons.swap_horiz, size: 20, color: colorScheme.onSurfaceVariant),
                    tooltip: 'Replace EPUB file',
                    onPressed: () => _importEpub(context, ref, replace: true),
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: hasEpub
                ? () => context.pushNamed('reader', pathParameters: {'id': '${book.id}'})
                : () => _importEpub(context, ref),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
      loading: () => const Card(
        child: ListTile(
          leading: CircleAvatar(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          title: Text('EPUB Reader'),
          subtitle: Text('Loading...'),
        ),
      ),
      error: (_, __) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.upload_file, color: colorScheme.onPrimaryContainer),
          ),
          title: const Text('Import EPUB'),
          subtitle: const Text('Import an EPUB file to read in-app'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _importEpub(context, ref),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _importEpub(BuildContext context, WidgetRef ref, {bool replace = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result == null || result.files.isEmpty) return;
    final sourcePath = result.files.first.path;
    if (sourcePath == null) return;

    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(epubServiceProvider);
      final epubRepo = ref.read(epubRepositoryProvider);

      // Copy EPUB to app storage
      final destPath = await service.importEpub(sourcePath, book.id!);

      // Delete old entry if replacing
      if (replace) {
        await epubRepo.deleteByBookId(book.id!);
      }

      // Create DB entry
      await epubRepo.addEpubFile(EpubData(
        bookId: book.id!,
        filePath: destPath,
      ));

      // Parse to get metadata and update book if needed
      final parsed = await service.parseAndExtract(destPath);
      if (book.totalPages == 0 && parsed.totalChapters > 0) {
        await ref.read(bookRepositoryProvider).updateBook(
          book.copyWith(totalPages: parsed.totalChapters),
        );
      }

      if (context.mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('EPUB imported: ${parsed.title} (${parsed.totalChapters} chapters)')),
        );
        // Navigate to reader
        context.pushNamed('reader', pathParameters: {'id': '${book.id}'});
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import EPUB: $e')),
        );
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? count;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count != null && count! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
