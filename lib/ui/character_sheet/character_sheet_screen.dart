import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/services/stat_parser.dart';
import '../../providers/providers.dart';

class CharacterSheetScreen extends ConsumerStatefulWidget {
  final int bookId;

  const CharacterSheetScreen({super.key, required this.bookId});

  @override
  ConsumerState<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends ConsumerState<CharacterSheetScreen> {
  int? _selectedSheetId;

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(characterSheetDaoProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Sheets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create new sheet',
            onPressed: () => _createSheet(context),
          ),
        ],
      ),
      body: StreamBuilder<List<CharacterSheet>>(
        stream: dao.watchSheetsByBook(widget.bookId),
        builder: (context, snapshot) {
          final sheets = snapshot.data ?? [];

          if (sheets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No character sheets yet', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Select text in the reader to auto-parse stats,\nor create a sheet manually.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _createSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Sheet'),
                  ),
                ],
              ),
            );
          }

          if (_selectedSheetId == null && sheets.isNotEmpty) {
            _selectedSheetId = sheets.first.id;
          }

          return Column(
            children: [
              if (sheets.length > 1)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: sheets.length,
                    itemBuilder: (context, i) {
                      final sheet = sheets[i];
                      final selected = sheet.id == _selectedSheetId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8, top: 8),
                        child: ChoiceChip(
                          label: Text(sheet.name),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedSheetId = sheet.id),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: _selectedSheetId != null
                    ? _SheetContent(
                        sheetId: _selectedSheetId!,
                        onDelete: () {
                          dao.deleteSheet(_selectedSheetId!);
                          dao.deleteEntriesBySheet(_selectedSheetId!);
                          setState(() => _selectedSheetId = null);
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createSheet(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Character Sheet'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Character Name', border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final dao = ref.read(characterSheetDaoProvider);
              final id = await dao.insertSheet(CharacterSheetsCompanion(
                bookId: Value(widget.bookId),
                name: Value(name),
                lastUpdatedAt: Value(DateTime.now()),
              ));
              setState(() => _selectedSheetId = id);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _SheetContent extends ConsumerWidget {
  final int sheetId;
  final VoidCallback onDelete;

  const _SheetContent({required this.sheetId, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(characterSheetDaoProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<CharacterSheet?>(
      future: dao.getSheetById(sheetId),
      builder: (context, sheetSnap) {
        final sheet = sheetSnap.data;
        if (sheet == null) return const SizedBox.shrink();

        return StreamBuilder<List<CharacterSheetEntry>>(
          stream: dao.watchEntriesBySheet(sheetId),
          builder: (context, entriesSnap) {
            final entries = entriesSnap.data ?? [];

            final resources = entries.where((e) => e.category == SheetCategory.resource).toList();
            final stats = entries.where((e) => e.category == SheetCategory.stat).toList();
            final skills = entries.where((e) => e.category == SheetCategory.skill).toList();
            final abilities = entries.where((e) => e.category == SheetCategory.ability).toList();
            final custom = entries.where((e) => e.category == SheetCategory.custom).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header card — tap name to rename
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _renameSheet(context, ref, sheet),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        sheet.name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.edit, size: 16, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'rename') _renameSheet(context, ref, sheet);
                                if (v == 'edit_meta') _editMeta(context, ref, sheet);
                                if (v == 'delete') _confirmDelete(context, onDelete);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.edit), title: Text('Rename'), dense: true, contentPadding: EdgeInsets.zero)),
                                const PopupMenuItem(value: 'edit_meta', child: ListTile(leading: Icon(Icons.tune), title: Text('Edit Level/Class'), dense: true, contentPadding: EdgeInsets.zero)),
                                PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: colorScheme.error), title: Text('Delete Sheet', style: TextStyle(color: colorScheme.error)), dense: true, contentPadding: EdgeInsets.zero)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _editMeta(context, ref, sheet),
                          child: Row(
                            children: [
                              if (sheet.level != null)
                                _Badge('Lv. ${sheet.level}', colorScheme.tertiary, colorScheme.onTertiary),
                              if (sheet.className != null) ...[
                                const SizedBox(width: 8),
                                _Badge(sheet.className!, colorScheme.secondary, colorScheme.onSecondary),
                              ],
                              if (sheet.level == null && sheet.className == null)
                                Text('Tap to set level & class', style: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (resources.isNotEmpty) ...[
                  _SectionHeader('Resources', Icons.favorite, colorScheme.error),
                  ...resources.map((e) => _EditableResourceTile(entry: e, dao: dao)),
                  const SizedBox(height: 12),
                ],

                if (stats.isNotEmpty) ...[
                  _SectionHeader('Stats', Icons.bar_chart, colorScheme.primary),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: stats.map((e) => _EditableStatChip(entry: e, dao: dao)).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                if (skills.isNotEmpty) ...[
                  _SectionHeader('Skills', Icons.auto_awesome, colorScheme.tertiary),
                  ...skills.map((e) => _EditableEntryTile(entry: e, dao: dao)),
                  const SizedBox(height: 12),
                ],

                if (abilities.isNotEmpty) ...[
                  _SectionHeader('Abilities', Icons.flash_on, Colors.amber),
                  ...abilities.map((e) => _EditableEntryTile(entry: e, dao: dao)),
                  const SizedBox(height: 12),
                ],

                if (custom.isNotEmpty) ...[
                  _SectionHeader('Info', Icons.info_outline, colorScheme.onSurfaceVariant),
                  ...custom.map((e) => _EditableEntryTile(entry: e, dao: dao)),
                  const SizedBox(height: 12),
                ],

                if (entries.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No stats yet.\nSelect text in the reader and tap "Update Sheet" to parse stats.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _addEntry(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Entry'),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  void _renameSheet(BuildContext context, WidgetRef ref, CharacterSheet sheet) {
    final nameCtrl = TextEditingController(text: sheet.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Character'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Character Name', border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          onSubmitted: (_) {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(ctx);
            ref.read(characterSheetDaoProvider).updateSheetName(sheetId, name);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              ref.read(characterSheetDaoProvider).updateSheetName(sheetId, name);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editMeta(BuildContext context, WidgetRef ref, CharacterSheet sheet) {
    final levelCtrl = TextEditingController(text: sheet.level?.toString() ?? '');
    final classCtrl = TextEditingController(text: sheet.className ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Level & Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'Level', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: classCtrl, decoration: const InputDecoration(labelText: 'Class/Job', border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(characterSheetDaoProvider).updateSheetMeta(
                sheetId,
                level: int.tryParse(levelCtrl.text),
                className: classCtrl.text.trim().isEmpty ? null : classCtrl.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sheet?'),
        content: const Text('This will permanently delete this character sheet and all its entries.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addEntry(BuildContext context, WidgetRef ref) {
    final keyCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    int category = SheetCategory.stat;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: SheetCategory.stat, child: Text('Stat')),
                  DropdownMenuItem(value: SheetCategory.resource, child: Text('Resource')),
                  DropdownMenuItem(value: SheetCategory.skill, child: Text('Skill')),
                  DropdownMenuItem(value: SheetCategory.ability, child: Text('Ability')),
                  DropdownMenuItem(value: SheetCategory.custom, child: Text('Info')),
                ],
                onChanged: (v) => setDialogState(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              TextField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (keyCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                ref.read(characterSheetDaoProvider).upsertEntry(sheetId, category, keyCtrl.text.trim(), valueCtrl.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge(this.text, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _EditableResourceTile extends StatelessWidget {
  final CharacterSheetEntry entry;
  final dynamic dao;
  const _EditableResourceTile({required this.entry, required this.dao});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parts = entry.entryValue.replaceAll(',', '').split('/');
    double? progress;
    if (parts.length == 2) {
      final current = double.tryParse(parts[0].trim());
      final max = double.tryParse(parts[1].trim());
      if (current != null && max != null && max > 0) {
        progress = (current / max).clamp(0.0, 1.0);
      }
    }
    final barColor = _resourceColor(entry.entryKey);

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (_) => dao.deleteEntry(entry.id),
      child: InkWell(
        onTap: () => _editEntry(context, entry, dao),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.entryKey, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.entryValue, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, size: 12, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    ],
                  ),
                ],
              ),
              if (progress != null) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: barColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _resourceColor(String key) {
    switch (key.toUpperCase()) {
      case 'HP': return Colors.red;
      case 'MP': return Colors.blue;
      case 'SP': return Colors.green;
      default: return Colors.orange;
    }
  }
}

class _EditableStatChip extends StatelessWidget {
  final CharacterSheetEntry entry;
  final dynamic dao;
  const _EditableStatChip({required this.entry, required this.dao});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _editEntry(context, entry, dao),
      onLongPress: () => _confirmDeleteEntry(context, entry, dao),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(entry.entryKey, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(entry.entryValue, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _EditableEntryTile extends StatelessWidget {
  final CharacterSheetEntry entry;
  final dynamic dao;
  const _EditableEntryTile({required this.entry, required this.dao});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (_) => dao.deleteEntry(entry.id),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(entry.entryKey),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.entryValue, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          ],
        ),
        onTap: () => _editEntry(context, entry, dao),
      ),
    );
  }
}

void _editEntry(BuildContext context, CharacterSheetEntry entry, dynamic dao) {
  final keyCtrl = TextEditingController(text: entry.entryKey);
  final valueCtrl = TextEditingController(text: entry.entryValue);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyCtrl,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: valueCtrl,
            decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            _confirmDeleteEntry(context, entry, dao);
          },
          child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
        const Spacer(),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (keyCtrl.text.trim().isEmpty) return;
            Navigator.pop(ctx);
            dao.upsertEntry(entry.sheetId, entry.category, keyCtrl.text.trim(), valueCtrl.text.trim());
            // If key changed, delete the old entry
            if (keyCtrl.text.trim() != entry.entryKey) {
              dao.deleteEntry(entry.id);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void _confirmDeleteEntry(BuildContext context, CharacterSheetEntry entry, dynamic dao) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Entry?'),
      content: Text('Remove "${entry.entryKey}" from this sheet?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () {
            Navigator.pop(ctx);
            dao.deleteEntry(entry.id);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
