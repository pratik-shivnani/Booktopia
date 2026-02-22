import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/platform_image.dart'
    if (dart.library.io) '../common/platform_image_native.dart';

import '../../domain/models/character.dart';
import '../../providers/providers.dart';

class CharactersScreen extends ConsumerWidget {
  final int bookId;

  const CharactersScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charsAsync = ref.watch(charactersByBookProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Characters')),
      body: charsAsync.when(
        data: (characters) {
          if (characters.isEmpty) {
            return _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final c = characters[index];
              return Dismissible(
                key: ValueKey(c.id),
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
                  ref.read(characterRepositoryProvider).deleteCharacter(c.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${c.name}" deleted')),
                  );
                },
                child: _CharacterTile(
                  character: c,
                  onTap: () => _showEditDialog(context, ref, c),
                  onDelete: () => _confirmDelete(context, ref, c),
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

  void _showEditDialog(BuildContext context, WidgetRef ref, Character? character) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CharacterForm(
        bookId: bookId,
        character: character,
        onSave: (c) async {
          final repo = ref.read(characterRepositoryProvider);
          if (character != null) {
            await repo.updateCharacter(c);
          } else {
            await repo.addCharacter(c);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Character character) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text('Delete "${character.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(characterRepositoryProvider).deleteCharacter(character.id!);
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

class _CharacterTile extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CharacterTile({
    required this.character,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: fileExists(character.imagePath)
              ? fileImageProvider(character.imagePath!)
              : null,
          child: character.imagePath == null
              ? Text(
                  character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(character.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(character.role.label),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _CharacterForm extends StatefulWidget {
  final int bookId;
  final Character? character;
  final Future<void> Function(Character) onSave;

  const _CharacterForm({
    required this.bookId,
    this.character,
    required this.onSave,
  });

  @override
  State<_CharacterForm> createState() => _CharacterFormState();
}

class _CharacterFormState extends State<_CharacterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late CharacterRole _role;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character?.name ?? '');
    _descController = TextEditingController(text: widget.character?.description ?? '');
    _role = widget.character?.role ?? CharacterRole.supporting;
    _imagePath = widget.character?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final dest = await pickAndSaveImageTo('characters');
    if (dest != null) setState(() => _imagePath = dest);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final character = Character(
      id: widget.character?.id,
      bookId: widget.bookId,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      imagePath: _imagePath,
      role: _role,
    );

    await widget.onSave(character);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
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
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.character != null ? 'Edit Character' : 'Add Character',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Avatar
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: fileExists(_imagePath)
                        ? fileImageProvider(_imagePath!)
                        : null,
                    child: _imagePath == null
                        ? Icon(Icons.add_a_photo, color: colorScheme.onPrimaryContainer)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *', prefixIcon: Icon(Icons.person)),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Text('Role', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: CharacterRole.values.map((role) {
                  return ChoiceChip(
                    label: Text(role.label),
                    selected: _role == role,
                    onSelected: (_) => setState(() => _role = role),
                  );
                }).toList(),
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
          Icon(Icons.people_outline, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No characters yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Tap + to add a character', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
