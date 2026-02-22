import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Native implementation — uses dart:io File for local images.

Widget fileImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
  final file = File(path);
  if (!file.existsSync()) {
    return Builder(builder: (context) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    });
  }
  return Image.file(file, fit: fit);
}

bool fileExists(String? path) {
  if (path == null) return false;
  return File(path).existsSync();
}

ImageProvider? fileImageProvider(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  return FileImage(file);
}

Future<String?> pickAndSaveImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
  if (image == null) return null;

  final appDir = await getApplicationDocumentsDirectory();
  final coverDir = Directory(p.join(appDir.path, 'covers'));
  if (!coverDir.existsSync()) {
    coverDir.createSync(recursive: true);
  }
  final ext = p.extension(image.path);
  final destPath = p.join(coverDir.path, '${DateTime.now().millisecondsSinceEpoch}$ext');
  await File(image.path).copy(destPath);
  return destPath;
}

Future<String?> pickAndSaveImageTo(String subDir) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
  if (image == null) return null;

  final appDir = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(appDir.path, subDir));
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final ext = p.extension(image.path);
  final destPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}$ext');
  await File(image.path).copy(destPath);
  return destPath;
}

Future<String?> saveFileToCovers(String sourcePath) async {
  final appDir = await getApplicationDocumentsDirectory();
  final coverDir = Directory(p.join(appDir.path, 'covers'));
  if (!coverDir.existsSync()) {
    coverDir.createSync(recursive: true);
  }
  final ext = p.extension(sourcePath);
  final destPath = p.join(coverDir.path, '${DateTime.now().millisecondsSinceEpoch}$ext');
  await File(sourcePath).copy(destPath);
  return destPath;
}

void deleteFileIfExists(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  } catch (_) {}
}
