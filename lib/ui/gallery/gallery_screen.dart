import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../common/platform_image.dart'
    if (dart.library.io) '../common/platform_image_native.dart';

import '../../domain/models/book_image.dart';
import '../../providers/providers.dart';

class GalleryScreen extends ConsumerWidget {
  final int bookId;

  const GalleryScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(imagesByBookProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: imagesAsync.when(
        data: (images) {
          if (images.isEmpty) return _EmptyState();
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) => _ImageTile(
              image: images[index],
              onTap: () => _showFullImage(context, ref, images[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addImage(context, ref),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Future<void> _addImage(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200);
    if (picked == null) return;

    final dest = await saveFileToCovers(picked.path);
    if (dest == null) return;

    final bookImage = BookImage(
      bookId: bookId,
      path: dest,
      createdAt: DateTime.now(),
    );

    ref.read(bookImageRepositoryProvider).addImage(bookImage);
  }

  void _showFullImage(BuildContext context, WidgetRef ref, BookImage image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullImageScreen(
          image: image,
          onDelete: () {
            ref.read(bookImageRepositoryProvider).deleteImage(image.id!);
            deleteFileIfExists(image.path);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final BookImage image;
  final VoidCallback onTap;

  const _ImageTile({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: fileExists(image.path)
            ? fileImageWidget(image.path, fit: BoxFit.cover)
            : Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
              ),
      ),
    );
  }
}

class _FullImageScreen extends StatelessWidget {
  final BookImage image;
  final VoidCallback onDelete;

  const _FullImageScreen({required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: image.caption != null ? Text(image.caption!) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Image'),
                  content: const Text('Delete this image?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDelete();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: fileExists(image.path)
              ? fileImageWidget(image.path)
              : const Icon(Icons.broken_image, color: Colors.white, size: 64),
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
          Icon(Icons.photo_library_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No images yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Tap + to add an image', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
