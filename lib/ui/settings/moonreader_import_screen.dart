import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/moonreader_import_service.dart';
import '../../providers/providers.dart';

class MoonReaderImportScreen extends ConsumerStatefulWidget {
  const MoonReaderImportScreen({super.key});

  @override
  ConsumerState<MoonReaderImportScreen> createState() =>
      _MoonReaderImportScreenState();
}

class _MoonReaderImportScreenState
    extends ConsumerState<MoonReaderImportScreen> {
  MoonReaderImportService? _service;
  MoonReaderBackup? _backup;
  String? _backupPath;
  bool _loading = false;
  bool _importing = false;
  String? _error;
  ImportResult? _result;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _service = MoonReaderImportService(ref.read(databaseProvider));
  }

  Future<void> _pickBackup() async {
    setState(() {
      _loading = true;
      _error = null;
      _backup = null;
      _result = null;
      _selectedIndices.clear();
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _loading = false);
        return;
      }

      final path = result.files.single.path!;
      if (!path.endsWith('.mrpro')) {
        setState(() {
          _loading = false;
          _error = 'Please select a .mrpro file (Moon+ Reader backup)';
        });
        return;
      }

      _backupPath = path;
      final backup = await _service!.parseBackup(path);

      if (mounted) {
        setState(() {
          _backup = backup;
          _loading = false;
          // Select all books by default
          _selectedIndices.addAll(
            List.generate(backup.books.length, (i) => i),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to parse backup: $e';
        });
      }
    }
  }

  Future<void> _importSelected() async {
    if (_backup == null || _backupPath == null || _selectedIndices.isEmpty) {
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
    });

    try {
      final result = await _service!.importBackup(
        _backupPath!,
        _backup!,
        selectedBookIndices: _selectedIndices,
      );

      if (mounted) {
        setState(() {
          _importing = false;
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _importing = false;
          _error = 'Import failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Moon+ Reader'),
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Parsing backup...'),
                ],
              ),
            )
          : _importing
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Importing books...'),
                    ],
                  ),
                )
              : _result != null
                  ? _buildResult(colorScheme, textTheme)
                  : _backup != null
                      ? _buildBookList(colorScheme, textTheme)
                      : _buildPickerPrompt(colorScheme, textTheme),
    );
  }

  Widget _buildPickerPrompt(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_upload_outlined,
                size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Import Moon+ Reader Backup',
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a .mrpro backup file to import your books, '
              'reading progress, highlights, and notes.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'To create a backup in Moon+ Reader:\n'
              'Menu → Backup & Restore → Backup to local storage',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _pickBackup,
              icon: const Icon(Icons.folder_open),
              label: const Text('Select .mrpro File'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: colorScheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _error!,
                          style:
                              TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(ColorScheme colorScheme, TextTheme textTheme) {
    final books = _backup!.books;

    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              Icon(Icons.menu_book, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found ${books.length} book(s)',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_backup!.notes.length} highlights/notes, '
                      '${_backup!.positions.length} reading positions',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIndices.length == books.length) {
                      _selectedIndices.clear();
                    } else {
                      _selectedIndices.addAll(
                        List.generate(books.length, (i) => i),
                      );
                    }
                  });
                },
                child: Text(
                  _selectedIndices.length == books.length
                      ? 'Deselect All'
                      : 'Select All',
                ),
              ),
            ],
          ),
        ),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!,
                    style: TextStyle(color: colorScheme.onErrorContainer)),
              ),
            ),
          ),

        // Book list
        Expanded(
          child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final selected = _selectedIndices.contains(index);

              // Find stats
              final lowerFilename = book.filename.toLowerCase();
              String progressStr = '';
              for (final entry in _backup!.positions.entries) {
                if (entry.key == lowerFilename ||
                    lowerFilename.endsWith(entry.key.split('/').last)) {
                  progressStr =
                      '${(entry.value.progressPercent * 100).toStringAsFixed(1)}%';
                  break;
                }
              }

              final noteCount = _backup!.notes
                  .where((n) =>
                      n.bookTitle == book.title ||
                      n.filename.toLowerCase() == lowerFilename)
                  .length;

              final hasEpub = book.epubTagIndex != null;

              return CheckboxListTile(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedIndices.add(index);
                    } else {
                      _selectedIndices.remove(index);
                    }
                  });
                },
                title: Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [
                    if (book.author.isNotEmpty) book.author,
                    if (progressStr.isNotEmpty) 'Progress: $progressStr',
                    if (noteCount > 0) '$noteCount notes',
                    if (hasEpub) 'EPUB included',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
                secondary: Icon(
                  hasEpub ? Icons.book : Icons.book_outlined,
                  color: hasEpub
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),

        // Import button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  _selectedIndices.isEmpty ? null : _importSelected,
              icon: const Icon(Icons.download),
              label: Text(
                  'Import ${_selectedIndices.length} Book(s)'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(ColorScheme colorScheme, TextTheme textTheme) {
    final r = _result!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('Import Complete!', style: textTheme.headlineSmall),
            const SizedBox(height: 24),

            _resultRow(Icons.book, '${r.booksImported} books imported'),
            _resultRow(Icons.highlight, '${r.highlightsImported} highlights'),
            _resultRow(Icons.note, '${r.notesImported} bookmarks/notes'),
            _resultRow(Icons.file_copy, '${r.epubsCopied} EPUBs copied'),

            if (r.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...r.warnings.map((w) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      w,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )),
            ],

            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _backup = null;
                      _result = null;
                      _backupPath = null;
                      _selectedIndices.clear();
                    });
                  },
                  child: const Text('Import Another'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
