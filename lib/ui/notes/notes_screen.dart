import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/note.dart';
import '../../providers/providers.dart';

class NotesScreen extends ConsumerWidget {
  final int bookId;

  const NotesScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesByBookProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) return _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final n = notes[index];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                confirmDismiss: (_) async => true,
                onDismissed: (_) {
                  ref.read(noteRepositoryProvider).deleteNote(n.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
                },
                child: _NoteTile(
                  note: n,
                  onTap: () => _showEditDialog(context, ref, n),
                  onDelete: () => _confirmDelete(context, ref, n),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Note? note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _NoteForm(
        bookId: bookId,
        note: note,
        onSave: (n) async {
          final repo = ref.read(noteRepositoryProvider);
          if (note != null) {
            await repo.updateNote(n);
          } else {
            await repo.addNote(n);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(noteRepositoryProvider).deleteNote(note.id!);
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

class _NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteTile({required this.note, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.pageNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'p. ${note.pageNumber}',
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSecondaryContainer),
                      ),
                    ),
                  if (note.chapter != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        note.chapter!,
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onTertiaryContainer),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    dateFormat.format(note.createdAt),
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: textTheme.bodyMedium,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteForm extends StatefulWidget {
  final int bookId;
  final Note? note;
  final Future<void> Function(Note) onSave;

  const _NoteForm({required this.bookId, this.note, required this.onSave});

  @override
  State<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<_NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final TextEditingController _pageController;
  late final TextEditingController _chapterController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _pageController = TextEditingController(
      text: widget.note?.pageNumber != null ? '${widget.note!.pageNumber}' : '',
    );
    _chapterController = TextEditingController(text: widget.note?.chapter ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final note = Note(
      id: widget.note?.id,
      bookId: widget.bookId,
      content: _contentController.text.trim(),
      pageNumber: int.tryParse(_pageController.text),
      chapter: _chapterController.text.trim().isEmpty ? null : _chapterController.text.trim(),
      createdAt: widget.note?.createdAt ?? DateTime.now(),
    );

    await widget.onSave(note);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.note != null ? 'Edit Note' : 'Add Note',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pageController,
                      decoration: const InputDecoration(labelText: 'Page', prefixIcon: Icon(Icons.bookmark)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _chapterController,
                      decoration: const InputDecoration(labelText: 'Chapter', prefixIcon: Icon(Icons.list)),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Note *',
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                validator: (v) => v == null || v.trim().isEmpty ? 'Note content is required' : null,
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No notes yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Tap + to add a note', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
