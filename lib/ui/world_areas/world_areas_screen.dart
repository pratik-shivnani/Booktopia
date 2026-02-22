import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/platform_image.dart'
    if (dart.library.io) '../common/platform_image_native.dart';

import '../../domain/models/world_area.dart';
import '../../providers/providers.dart';

class WorldAreasScreen extends ConsumerWidget {
  final int bookId;

  const WorldAreasScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(worldAreasByBookProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('World Areas')),
      body: areasAsync.when(
        data: (areas) {
          if (areas.isEmpty) return _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final a = areas[index];
              return Dismissible(
                key: ValueKey(a.id),
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
                  ref.read(worldAreaRepositoryProvider).deleteWorldArea(a.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${a.name}" deleted')),
                  );
                },
                child: _WorldAreaTile(
                  area: a,
                  onTap: () => _showEditDialog(context, ref, a),
                  onDelete: () => _confirmDelete(context, ref, a),
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

  void _showEditDialog(BuildContext context, WidgetRef ref, WorldArea? area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _WorldAreaForm(
        bookId: bookId,
        area: area,
        onSave: (a) async {
          final repo = ref.read(worldAreaRepositoryProvider);
          if (area != null) {
            await repo.updateWorldArea(a);
          } else {
            await repo.addWorldArea(a);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, WorldArea area) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete World Area'),
        content: Text('Delete "${area.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(worldAreaRepositoryProvider).deleteWorldArea(area.id!);
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

class _WorldAreaTile extends StatelessWidget {
  final WorldArea area;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WorldAreaTile({required this.area, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            if (fileExists(area.imagePath))
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: fileImageWidget(area.imagePath!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: Icon(Icons.public, color: colorScheme.onSecondaryContainer),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(area.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (area.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        area.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldAreaForm extends StatefulWidget {
  final int bookId;
  final WorldArea? area;
  final Future<void> Function(WorldArea) onSave;

  const _WorldAreaForm({required this.bookId, this.area, required this.onSave});

  @override
  State<_WorldAreaForm> createState() => _WorldAreaFormState();
}

class _WorldAreaFormState extends State<_WorldAreaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.area?.name ?? '');
    _descController = TextEditingController(text: widget.area?.description ?? '');
    _imagePath = widget.area?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final dest = await pickAndSaveImageTo('world_areas');
    if (dest != null) setState(() => _imagePath = dest);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final area = WorldArea(
      id: widget.area?.id,
      bookId: widget.bookId,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      imagePath: _imagePath,
    );

    await widget.onSave(area);
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
                widget.area != null ? 'Edit World Area' : 'Add World Area',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: fileExists(_imagePath)
                      ? fileImageWidget(_imagePath!, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 32, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 4),
                              Text('Add Image', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *', prefixIcon: Icon(Icons.public)),
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
          Icon(Icons.public, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No world areas yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Tap + to add a location', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
