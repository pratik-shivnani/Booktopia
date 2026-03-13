import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Checks GitHub Releases for a newer app version and downloads the APK.
class AppUpdateService {
  static const _storageKeyPat = 'github_pat';
  static const _storageKeyOwner = 'github_sync_owner';
  static const _apiBase = 'https://api.github.com';

  /// The source repo name (where APK releases are published).
  static const _sourceRepo = 'booktopia';

  /// Current app version — keep in sync with pubspec.yaml.
  static const currentVersion = '0.1.0';

  final FlutterSecureStorage _storage;

  AppUpdateService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// Check for a newer release. Returns release info or null if up-to-date.
  Future<ReleaseInfo?> checkForUpdate() async {
    final pat = await _storage.read(key: _storageKeyPat);
    final owner = await _storage.read(key: _storageKeyOwner);
    if (pat == null || owner == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_apiBase/repos/$owner/$_sourceRepo/releases/latest'),
        headers: {
          'Authorization': 'Bearer $pat',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';

      // Extract version from tag (e.g. "v0.2.0" → "0.2.0")
      final remoteVersion = tagName.replaceFirst(RegExp(r'^v'), '');
      if (remoteVersion.isEmpty) return null;

      if (!_isNewer(remoteVersion, currentVersion)) return null;

      // Find APK asset
      String? apkUrl;
      String? apkName;
      int? apkSize;
      final assets = data['assets'] as List? ?? [];
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          apkUrl = asset['url'] as String?;
          apkName = name;
          apkSize = asset['size'] as int?;
          break;
        }
      }

      return ReleaseInfo(
        version: remoteVersion,
        tagName: tagName,
        name: data['name'] as String? ?? tagName,
        body: data['body'] as String? ?? '',
        apkDownloadUrl: apkUrl,
        apkName: apkName,
        apkSize: apkSize,
      );
    } catch (_) {
      return null;
    }
  }

  /// Download the APK from a release asset URL.
  /// Returns the local file path of the downloaded APK.
  Future<String?> downloadApk(ReleaseInfo release) async {
    if (release.apkDownloadUrl == null) return null;

    final pat = await _storage.read(key: _storageKeyPat);
    if (pat == null) return null;

    try {
      // GitHub requires Accept: application/octet-stream for asset download
      final response = await http.get(
        Uri.parse(release.apkDownloadUrl!),
        headers: {
          'Authorization': 'Bearer $pat',
          'Accept': 'application/octet-stream',
        },
      );

      if (response.statusCode != 200) return null;

      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final filePath = p.join(dir.path, release.apkName ?? 'booktopia-update.apk');
      await File(filePath).writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (_) {
      return null;
    }
  }

  /// Compare two semver strings. Returns true if remote > current.
  static bool _isNewer(String remote, String current) {
    final rParts = remote.split('.').map(int.tryParse).toList();
    final cParts = current.split('.').map(int.tryParse).toList();

    for (int i = 0; i < 3; i++) {
      final r = i < rParts.length ? (rParts[i] ?? 0) : 0;
      final c = i < cParts.length ? (cParts[i] ?? 0) : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }
}

class ReleaseInfo {
  final String version;
  final String tagName;
  final String name;
  final String body;
  final String? apkDownloadUrl;
  final String? apkName;
  final int? apkSize;

  const ReleaseInfo({
    required this.version,
    required this.tagName,
    required this.name,
    required this.body,
    this.apkDownloadUrl,
    this.apkName,
    this.apkSize,
  });
}
