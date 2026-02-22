import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Stub implementation for web — local file system is not available.
/// On native platforms, this file is replaced via conditional import.

Widget fileImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('data:image/') ||
      path.startsWith('http://') ||
      path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (context, _, __) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        );
      },
    );
  }

  return Builder(builder: (context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  });
}

bool fileExists(String? path) {
  if (path == null || path.isEmpty) return false;
  return path.startsWith('data:image/') ||
      path.startsWith('http://') ||
      path.startsWith('https://');
}

ImageProvider? fileImageProvider(String path) {
  if (path.startsWith('data:image/') ||
      path.startsWith('http://') ||
      path.startsWith('https://')) {
    return NetworkImage(path);
  }
  return null;
}

String _mimeFromExtension(String? ext) {
  final e = (ext ?? '').toLowerCase();
  switch (e) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/png';
  }
}

Future<String?> _pickImageAsDataUrl() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null) return null;

  final mime = _mimeFromExtension(file.extension);
  final encoded = base64Encode(bytes);
  return 'data:$mime;base64,$encoded';
}

Future<String?> pickAndSaveImage() => _pickImageAsDataUrl();

Future<String?> pickAndSaveImageTo(String subDir) => _pickImageAsDataUrl();

Future<String?> saveFileToCovers(String sourcePath) async => sourcePath;

void deleteFileIfExists(String path) {}
