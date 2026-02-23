import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/services/book_lookup_service.dart';
import '../../domain/models/book_lookup_result.dart';

class BookImportSheet extends StatefulWidget {
  final void Function(BookLookupResult result) onSelect;

  const BookImportSheet({super.key, required this.onSelect});

  @override
  State<BookImportSheet> createState() => _BookImportSheetState();
}

class _BookImportSheetState extends State<BookImportSheet> {
  final _service = BookLookupService();
  final _searchController = TextEditingController();

  LookupSource _source = LookupSource.openLibrary;
  List<BookLookupResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().length < 2) return;
    _search(query.trim());
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = switch (_source) {
        LookupSource.googleBooks => await _service.searchGoogleBooks(query),
        LookupSource.openLibrary => await _service.searchOpenLibrary(query),
        LookupSource.epub => <BookLookupResult>[],
      };
      if (mounted) setState(() => _results = results);
    } on RateLimitException catch (_) {
      // Auto-fallback to Open Library on Google Books rate limit
      if (_source == LookupSource.googleBooks && mounted) {
        setState(() => _source = LookupSource.openLibrary);
        try {
          final fallbackResults = await _service.searchOpenLibrary(query);
          if (mounted) {
            setState(() {
              _results = fallbackResults;
              _error = 'Google Books rate limit hit — switched to Open Library.';
            });
          }
        } catch (e2) {
          if (mounted) setState(() => _error = 'Google Books rate-limited. Open Library also failed: $e2');
        }
      } else {
        if (mounted) setState(() => _error = 'Rate limit exceeded. Try again later.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickEpub() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );

      if (result == null || result.files.single.path == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final book = await _service.parseEpubFromPath(result.files.single.path!);
      if (mounted) {
        widget.onSelect(book);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to parse EPUB: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Import Book Details', style: textTheme.titleLarge),
            ),
            const SizedBox(height: 12),

            // Source tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<LookupSource>(
                segments: LookupSource.values
                    .map((s) => ButtonSegment(
                          value: s,
                          label: Text(s.label, style: const TextStyle(fontSize: 11)),
                          icon: Icon(
                            switch (s) {
                              LookupSource.googleBooks => Icons.search,
                              LookupSource.openLibrary => Icons.menu_book,
                              LookupSource.epub => Icons.upload_file,
                            },
                            size: 18,
                          ),
                        ))
                    .toList(),
                selected: {_source},
                onSelectionChanged: (v) {
                  setState(() {
                    _source = v.first;
                    _results = [];
                    _error = null;
                  });
                  if (_source == LookupSource.epub) {
                    _pickEpub();
                  } else if (_searchController.text.trim().length >= 2) {
                    _search(_searchController.text.trim());
                  }
                },
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(height: 12),

            // Search bar (hidden for EPUB)
            if (_source != LookupSource.epub)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, or ISBN...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _results = []);
                            },
                          )
                        : null,
                    isDense: true,
                  ),
                  onSubmitted: _onSearchSubmitted,
                  textInputAction: TextInputAction.search,
                ),
              ),

            if (_source == LookupSource.epub) ...[
              const SizedBox(height: 24),
              if (!_loading)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.upload_file, size: 48, color: colorScheme.primary),
                      const SizedBox(height: 12),
                      Text('Select an EPUB file to import', style: textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _pickEpub,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Choose EPUB'),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 8),

            // Loading / Error
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Results list
            if (_results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return _ResultTile(
                      result: _results[index],
                      onTap: () {
                        widget.onSelect(_results[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            else if (!_loading && _source != LookupSource.epub && _searchController.text.length >= 2)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text('No results found', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  final BookLookupResult result;
  final VoidCallback onTap;

  const _ResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 50,
                  height: 72,
                  child: result.coverUrl != null
                      ? Image.network(
                          result.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, st) => _placeholder(colorScheme),
                        )
                      : _placeholder(colorScheme),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.author,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (result.pageCount != null) ...[
                          Icon(Icons.pages, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text('${result.pageCount}p', style: textTheme.labelSmall),
                          const SizedBox(width: 8),
                        ],
                        if (result.rating != null) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${result.rating}', style: textTheme.labelSmall),
                          const SizedBox(width: 8),
                        ],
                        if (result.genre != null)
                          Expanded(
                            child: Text(
                              result.genre!,
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Source badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.source,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.menu_book, size: 24, color: cs.onSurfaceVariant),
    );
  }
}
