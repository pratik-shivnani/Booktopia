import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/platform_image.dart'
    if (dart.library.io) '../common/platform_image_native.dart';
import '../../data/services/book_lookup_service.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_lookup_result.dart';
import '../../providers/providers.dart';
import 'book_import_sheet.dart';

class AddEditBookScreen extends ConsumerStatefulWidget {
  final int? bookId;

  const AddEditBookScreen({super.key, this.bookId});

  @override
  ConsumerState<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends ConsumerState<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _currentPageController = TextEditingController();

  BookStatus _status = BookStatus.wishlist;
  double? _rating;
  String? _coverImagePath;
  bool _isLoading = false;
  bool _initialized = false;

  bool get isEditing => widget.bookId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    super.dispose();
  }

  void _initFromBook(Book book) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = book.title;
    _authorController.text = book.author;
    _genreController.text = book.genre ?? '';
    _totalPagesController.text = book.totalPages > 0 ? '${book.totalPages}' : '';
    _currentPageController.text = book.currentPage > 0 ? '${book.currentPage}' : '';
    _status = book.status;
    _rating = book.rating;
    _coverImagePath = book.coverImagePath;
  }

  Future<void> _pickCoverImage() async {
    final destPath = await pickAndSaveImage();
    if (destPath != null) setState(() => _coverImagePath = destPath);
  }

  void _showImportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BookImportSheet(
        onSelect: _applyLookupResult,
      ),
    );
  }

  Future<void> _applyLookupResult(BookLookupResult result) async {
    setState(() {
      _titleController.text = result.title;
      _authorController.text = result.author;
      if (result.genre != null) _genreController.text = result.genre!;
      if (result.pageCount != null) _totalPagesController.text = '${result.pageCount}';
      if (result.rating != null) _rating = result.rating!.clamp(1.0, 5.0).roundToDouble();
    });

    // Download cover image if available
    if (result.coverUrl != null) {
      final service = BookLookupService();
      final localPath = await service.downloadCover(result.coverUrl!);
      if (localPath != null && mounted) {
        setState(() => _coverImagePath = localPath);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported "${result.title}" from ${result.source}')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final totalPages = int.tryParse(_totalPagesController.text) ?? 0;
    final currentPage = int.tryParse(_currentPageController.text) ?? 0;

    final book = Book(
      id: widget.bookId,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      coverImagePath: _coverImagePath,
      genre: _genreController.text.trim().isEmpty ? null : _genreController.text.trim(),
      totalPages: totalPages,
      currentPage: currentPage,
      status: _status,
      rating: _rating,
      dateAdded: DateTime.now(),
    );

    try {
      final repo = ref.read(bookRepositoryProvider);
      if (isEditing) {
        await repo.updateBook(book);
      } else {
        await repo.addBook(book);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving book: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isEditing) {
      final bookAsync = ref.watch(bookByIdProvider(widget.bookId!));
      return bookAsync.when(
        data: (Book book) {
          _initFromBook(book);
          return _buildForm(context, colorScheme);
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      );
    }

    return _buildForm(context, colorScheme);
  }

  Widget _buildForm(BuildContext context, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add Book'),
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: _showImportSheet,
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Import book details',
            ),
          TextButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Import banner (only when adding)
            if (!isEditing) ...[
              Card(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                child: InkWell(
                  onTap: _showImportSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import book details',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                'Auto-fill from Google Books, Open Library, or an EPUB file',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Cover image
            Center(
              child: GestureDetector(
                onTap: _pickCoverImage,
                child: Container(
                  width: 140,
                  height: 200,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: fileExists(_coverImagePath)
                      ? fileImageWidget(_coverImagePath!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('Add Cover',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    )),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.book),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Author
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Author is required' : null,
            ),
            const SizedBox(height: 16),

            // Genre
            TextFormField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Pages row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalPagesController,
                    decoration: const InputDecoration(
                      labelText: 'Total Pages',
                      prefixIcon: Icon(Icons.pages),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _currentPageController,
                    decoration: const InputDecoration(
                      labelText: 'Current Page',
                      prefixIcon: Icon(Icons.bookmark),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status
            Text('Status', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: BookStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(status.label),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Rating
            Text('Rating', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = _rating == starValue ? null : starValue;
                    });
                  },
                  icon: Icon(
                    (_rating ?? 0) >= starValue ? Icons.star_rounded : Icons.star_border_rounded,
                    color: (_rating ?? 0) >= starValue
                        ? Colors.amber
                        : colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
