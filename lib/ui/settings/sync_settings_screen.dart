import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/app_update_service.dart';
import '../../data/services/github_sync_service.dart';
import '../../providers/providers.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  final _patController = TextEditingController();
  final _ownerController = TextEditingController();
  final _repoController = TextEditingController();
  bool _autoSync = false;
  bool _loading = true;
  bool _syncing = false;
  bool _obscurePat = true;
  bool _checkingUpdate = false;
  bool _downloading = false;
  double _downloadProgress = 0;
  String? _downloadedApkPath;
  String? _connectionStatus;
  DateTime? _lastSync;
  ReleaseInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _patController.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final service = ref.read(githubSyncServiceProvider);
    await service.loadConfig();
    final pat = await service.pat;
    final owner = await service.owner;
    final repo = await service.repo;
    final autoSync = await service.autoSyncEnabled;
    final lastSync = await service.lastSyncTime;

    if (mounted) {
      setState(() {
        _patController.text = pat ?? '';
        _ownerController.text = owner ?? '';
        _repoController.text = repo ?? '';
        _autoSync = autoSync;
        _lastSync = lastSync;
        _loading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    final service = ref.read(githubSyncServiceProvider);
    await service.saveConfig(
      pat: _patController.text.trim(),
      owner: _ownerController.text.trim(),
      repo: _repoController.text.trim(),
    );
    await service.setAutoSync(_autoSync);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() => _connectionStatus = null);
    final service = ref.read(githubSyncServiceProvider);
    await service.saveConfig(
      pat: _patController.text.trim(),
      owner: _ownerController.text.trim(),
      repo: _repoController.text.trim(),
    );
    final error = await service.testConnection();
    if (mounted) {
      setState(() {
        _connectionStatus = error ?? 'Connected successfully!';
      });
    }
  }

  Future<void> _pushAll() async {
    setState(() => _syncing = true);
    try {
      final service = ref.read(githubSyncServiceProvider);
      await service.pushAll();
      final lastSync = await service.lastSyncTime;
      if (mounted) {
        setState(() {
          _lastSync = lastSync;
          _syncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Push failed: $e')),
        );
      }
    }
  }

  Future<void> _pullAll() async {
    setState(() => _syncing = true);
    try {
      final service = ref.read(githubSyncServiceProvider);
      await service.pullAll();
      final lastSync = await service.lastSyncTime;
      if (mounted) {
        setState(() {
          _lastSync = lastSync;
          _syncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pull complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pull failed: $e')),
        );
      }
    }
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _checkingUpdate = true;
      _updateInfo = null;
    });
    try {
      final updateService = ref.read(appUpdateServiceProvider);
      final info = await updateService.checkForUpdate();
      if (mounted) {
        setState(() {
          _checkingUpdate = false;
          _updateInfo = info;
        });
        if (info == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You\'re on the latest version (${AppUpdateService.currentVersion})'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _checkingUpdate = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update check failed: $e')),
        );
      }
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_updateInfo == null) return;
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
      _downloadedApkPath = null;
    });

    try {
      final updateService = ref.read(appUpdateServiceProvider);
      final path = await updateService.downloadApk(
        _updateInfo!,
        onProgress: (progress) {
          if (mounted) setState(() => _downloadProgress = progress);
        },
      );

      if (mounted) {
        setState(() {
          _downloading = false;
          _downloadedApkPath = path;
        });

        if (path != null) {
          // Auto-trigger install
          _installApk();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download failed — check your connection and PAT')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _installApk() async {
    if (_downloadedApkPath == null) return;

    final success = await AppUpdateService.installApk(_downloadedApkPath!);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch installer. Check app install permissions in Settings.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save settings',
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // GitHub Configuration Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.key, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('GitHub Configuration',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _patController,
                    obscureText: _obscurePat,
                    decoration: InputDecoration(
                      labelText: 'Personal Access Token',
                      helperText: 'Needs "repo" scope',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePat ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePat = !_obscurePat),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ownerController,
                    decoration: const InputDecoration(
                      labelText: 'GitHub Username',
                      helperText: 'Your GitHub username or org',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repoController,
                    decoration: const InputDecoration(
                      labelText: 'Repository Name',
                      helperText: 'e.g. booktopia-data (must exist, private recommended)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.wifi_tethering),
                      label: const Text('Test Connection'),
                    ),
                  ),
                  if (_connectionStatus != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _connectionStatus == 'Connected successfully!'
                            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                            : colorScheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _connectionStatus == 'Connected successfully!'
                                ? Icons.check_circle
                                : Icons.error,
                            size: 18,
                            color: _connectionStatus == 'Connected successfully!'
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _connectionStatus!,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sync Options Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Sync Options',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Auto-sync on launch'),
                    subtitle: const Text('Pull updates when the app opens'),
                    value: _autoSync,
                    onChanged: (v) => setState(() => _autoSync = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_lastSync != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Last synced: ${_formatDate(_lastSync!)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Manual Sync Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Manual Sync',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_syncing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Syncing...'),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _pushAll,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Push All Data to GitHub'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: _pullAll,
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Pull All Data from GitHub'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Update Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.system_update, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('App Update',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current version: ${AppUpdateService.currentVersion}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  if (_checkingUpdate)
                    const Center(child: CircularProgressIndicator())
                  else if (_updateInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update available: v${_updateInfo!.version}',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (_updateInfo!.body.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _updateInfo!.body.length > 200
                                  ? '${_updateInfo!.body.substring(0, 200)}...'
                                  : _updateInfo!.body,
                              style: textTheme.bodySmall,
                            ),
                          ],
                          if (_updateInfo!.apkSize != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Size: ${(_updateInfo!.apkSize! / 1024 / 1024).toStringAsFixed(1)} MB',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_downloading) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _downloadProgress > 0 ? _downloadProgress : null,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _downloadProgress > 0
                            ? 'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                            : 'Starting download...',
                        style: textTheme.bodySmall,
                      ),
                    ] else if (_downloadedApkPath != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _installApk,
                          icon: const Icon(Icons.install_mobile),
                          label: const Text('Install Update'),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _downloadAndInstall,
                          icon: const Icon(Icons.download),
                          label: const Text('Download & Install'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: (_checkingUpdate || _downloading) ? null : _checkForUpdate,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Check for Updates'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info card
          Card(
            color: colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('How it works',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Create a private repo on GitHub (e.g. booktopia-data)\n'
                    '• Generate a PAT with "repo" scope at github.com/settings/tokens\n'
                    '• Push saves all your books, characters, sheets, notes, etc.\n'
                    '• Pull imports data + applies helper agent updates\n'
                    '• The Windows helper agent can analyze your EPUBs and push updates here',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
