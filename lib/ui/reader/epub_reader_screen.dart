import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import '../../data/database/app_database.dart' show ReaderBookmarksCompanion, ReaderHighlightsCompanion, CharacterSheetsCompanion, CharacterSheet;
import '../../data/services/entity_extractor.dart';
import '../../data/services/epub_service.dart';
import '../../data/services/stat_parser.dart';
import '../../domain/models/epub_data.dart';
import '../../domain/models/mindmap_edge.dart' as domain_edge;
import '../../domain/models/mindmap_node.dart' as domain_node;
import '../../providers/providers.dart';
import 'highlight_js.dart';
import 'reader_settings_sheet.dart';

class EpubReaderScreen extends ConsumerStatefulWidget {
  final int bookId;

  const EpubReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends ConsumerState<EpubReaderScreen> {
  ParsedEpub? _parsedEpub;
  EpubData? _epubData;
  int _currentChapter = 0;
  bool _loading = true;
  String? _error;
  InAppWebViewController? _webViewController;
  bool _tocOpen = false;
  bool _bookmarksOpen = false;
  Timer? _saveTimer;
  double _currentScroll = 0.0;

  // Reader settings (kept in sync with DB)
  int _fontSize = 18;
  String _fontFamily = 'serif';
  ReaderTheme _readerTheme = ReaderTheme.light;
  double _lineHeight = 1.7;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _savePosition();
    super.dispose();
  }

  Future<void> _loadEpub() async {
    try {
      final epubData = await ref.read(epubRepositoryProvider).getByBookId(widget.bookId);
      if (epubData == null) {
        setState(() {
          _error = 'No EPUB file associated with this book.';
          _loading = false;
        });
        return;
      }

      _epubData = epubData;
      _currentChapter = epubData.currentChapterIndex;
      _currentScroll = epubData.scrollPosition;
      _fontSize = epubData.fontSize;
      _fontFamily = epubData.fontFamily;
      _readerTheme = epubData.readerTheme;
      _lineHeight = epubData.lineHeight;

      final service = ref.read(epubServiceProvider);
      final parsed = await service.parseAndExtract(epubData.filePath);

      setState(() {
        _parsedEpub = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load EPUB: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadChapter(int index) async {
    if (_parsedEpub == null || index < 0 || index >= _parsedEpub!.totalChapters) return;

    setState(() {
      _currentChapter = index;
      _currentScroll = 0.0;
    });

    final html = await ref.read(epubServiceProvider).getChapterHtml(_parsedEpub!, index);
    final styledHtml = _wrapWithReaderStyles(html);
    await _webViewController?.loadData(
      data: styledHtml,
      baseUrl: WebUri('file://${_parsedEpub!.extractionDir}/'),
      mimeType: 'text/html',
      encoding: 'utf-8',
    );

    _savePosition();
  }

  // --- Theme CSS generation ---

  String _cssFontStack() {
    switch (_fontFamily) {
      case 'sans-serif':
        return "'-apple-system', 'Helvetica Neue', 'Arial', sans-serif";
      case 'monospace':
        return "'Courier New', 'Courier', monospace";
      case 'system-ui':
        return 'system-ui, sans-serif';
      case 'serif':
      default:
        return "'Georgia', 'Noto Serif', serif";
    }
  }

  String _cssColors() {
    switch (_readerTheme) {
      case ReaderTheme.dark:
        return 'color: #CCCCCC; background: #1A1A1A;';
      case ReaderTheme.sepia:
        return 'color: #5B4636; background: #F5E6C8;';
      case ReaderTheme.light:
      default:
        return 'color: #222222; background: #FAFAFA;';
    }
  }

  String _cssLinkColor() {
    switch (_readerTheme) {
      case ReaderTheme.dark:
        return '#B39DDB';
      case ReaderTheme.sepia:
        return '#8B6914';
      case ReaderTheme.light:
      default:
        return '#6750A4';
    }
  }

  String _buildReaderCss() {
    return '''
      body {
        font-family: ${_cssFontStack()};
        font-size: ${_fontSize}px;
        line-height: $_lineHeight;
        ${_cssColors()}
        padding: 16px 20px 80px 20px;
        margin: 0;
        word-wrap: break-word;
        overflow-wrap: break-word;
        -webkit-text-size-adjust: 100%;
        transition: background 0.3s, color 0.3s;
      }
      img {
        max-width: 100%;
        height: auto;
      }
      h1, h2, h3, h4, h5, h6 {
        line-height: 1.3;
        margin-top: 1.5em;
      }
      p {
        margin-bottom: 0.8em;
      }
      a {
        color: ${_cssLinkColor()};
      }
    ''';
  }

  String _wrapWithReaderStyles(String html) {
    final readerCss = '''
    <style id="booktopia-reader-style">
      ${_buildReaderCss()}
    </style>
    <script>
      window.addEventListener('scroll', function() {
        var scrollPos = window.scrollY / (document.documentElement.scrollHeight - window.innerHeight);
        if (isNaN(scrollPos)) scrollPos = 0;
        window.flutter_inappwebview.callHandler('onScroll', scrollPos);
      });
      function updateReaderStyle(css) {
        var el = document.getElementById('booktopia-reader-style');
        if (el) el.textContent = css;
      }
    </script>
    <script>$highlightJs</script>
    ''';

    if (html.contains('</head>')) {
      return html.replaceFirst('</head>', '$readerCss</head>');
    } else if (html.contains('<body')) {
      return html.replaceFirst('<body', '$readerCss<body');
    } else {
      return '<html><head>$readerCss</head><body>$html</body></html>';
    }
  }

  /// Update CSS in the WebView without reloading the chapter.
  Future<void> _applyStyleUpdate() async {
    final css = _buildReaderCss().replaceAll('\n', ' ').replaceAll("'", "\\'");
    await _webViewController?.evaluateJavascript(source: "updateReaderStyle('$css');");
  }

  void _onSettingsChanged(EpubData updated) {
    setState(() {
      _fontSize = updated.fontSize;
      _fontFamily = updated.fontFamily;
      _readerTheme = updated.readerTheme;
      _lineHeight = updated.lineHeight;
    });
    _applyStyleUpdate();

    // Persist
    if (_epubData?.id != null) {
      ref.read(epubRepositoryProvider).updateReaderSettings(
        _epubData!.id!,
        fontSize: _fontSize,
        fontFamily: _fontFamily,
        readerTheme: _readerTheme,
        lineHeight: _lineHeight,
      );
    }
  }

  void _savePosition() {
    if (_epubData?.id == null) return;
    ref.read(epubRepositoryProvider).updateReadingPosition(
      _epubData!.id!,
      _currentChapter,
      _currentScroll,
    );

    // Also update book progress
    if (_parsedEpub != null && _parsedEpub!.totalChapters > 0) {
      final progress = (_currentChapter + _currentScroll) / _parsedEpub!.totalChapters;
      final bookRepo = ref.read(bookRepositoryProvider);
      bookRepo.watchBookById(widget.bookId).first.then((book) {
        final totalPages = book.totalPages > 0 ? book.totalPages : _parsedEpub!.totalChapters;
        final currentPage = ((progress) * totalPages).round().clamp(0, totalPages);
        if (currentPage != book.currentPage) {
          bookRepo.updateBook(book.copyWith(currentPage: currentPage));
        }
      });
    }
  }

  void _debounceSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 3), _savePosition);
  }

  // --- Highlight support ---

  Map<String, dynamic>? _pendingSelection;

  static const _highlightColors = [
    0xFFFFEB3B, // Yellow
    0xFF81C784, // Green
    0xFF64B5F6, // Blue
    0xFFE57373, // Red
    0xFFFFAB91, // Orange
    0xFFCE93D8, // Purple
  ];

  void _onTextSelected(Map<String, dynamic> selectionData) {
    _pendingSelection = selectionData;
    _showHighlightMenu(selectionData['text'] as String);
  }

  void _showHighlightMenu(String selectedText) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Highlight', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '"${selectedText.length > 100 ? '${selectedText.substring(0, 100)}...' : selectedText}"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _highlightColors.map((c) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _createHighlight(c);
                  },
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _createHighlightWithNote();
              },
              icon: const Icon(Icons.note_add),
              label: const Text('Highlight with Note'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pop(ctx);
                _updateCharacterSheet(selectedText);
              },
              icon: const Icon(Icons.person_search),
              label: const Text('Update Character Sheet'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createHighlight(int color, {String? note}) async {
    if (_pendingSelection == null) return;
    final sel = _pendingSelection!;
    final dao = ref.read(readerHighlightDaoProvider);

    final rangeStart = '${sel['startXPath']}|${sel['startOffset']}';
    final rangeEnd = '${sel['endXPath']}|${sel['endOffset']}';

    final id = await dao.insertHighlight(ReaderHighlightsCompanion(
      bookId: Value(widget.bookId),
      chapterIndex: Value(_currentChapter),
      highlightText: Value(sel['text'] as String),
      rangeStart: Value(rangeStart),
      rangeEnd: Value(rangeEnd),
      color: Value(color),
      note: Value(note),
      createdAt: Value(DateTime.now()),
    ));

    // Apply highlight in WebView
    final colorHex = 'rgba(${(color >> 16) & 0xFF}, ${(color >> 8) & 0xFF}, ${color & 0xFF}, 0.4)';
    await _webViewController?.evaluateJavascript(
      source: jsApplyHighlight(
        id: id,
        rangeStart: sel['startXPath'] as String,
        startOffset: sel['startOffset'] as int,
        rangeEnd: sel['endXPath'] as String,
        endOffset: sel['endOffset'] as int,
        colorHex: colorHex,
      ),
    );

    // Clear selection
    await _webViewController?.evaluateJavascript(source: 'window.getSelection().removeAllRanges();');
    _pendingSelection = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(note != null ? 'Highlighted with note' : 'Highlighted'), duration: const Duration(seconds: 1)),
      );
    }
  }

  void _createHighlightWithNote() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Your note...',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _createHighlight(_highlightColors[0], note: noteController.text.trim().isEmpty ? null : noteController.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onHighlightTap(int highlightId) {
    final dao = ref.read(readerHighlightDaoProvider);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return FutureBuilder(
          future: dao.watchByBookAndChapter(widget.bookId, _currentChapter).first,
          builder: (context, snapshot) {
            final highlights = snapshot.data ?? [];
            final hl = highlights.where((h) => h.id == highlightId).firstOrNull;
            if (hl == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    '"${hl.highlightText.length > 150 ? '${hl.highlightText.substring(0, 150)}...' : hl.highlightText}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hl.note != null && hl.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.note, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(hl.note!, style: Theme.of(context).textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _editHighlightNote(highlightId, hl.note);
                          },
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: Text(hl.note != null ? 'Edit Note' : 'Add Note'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await dao.deleteHighlight(highlightId);
                            await _webViewController?.evaluateJavascript(source: jsRemoveHighlight(highlightId));
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Remove'),
                          style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editHighlightNote(int highlightId, String? currentNote) {
    final controller = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Your note...', border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final text = controller.text.trim();
              ref.read(readerHighlightDaoProvider).updateNote(highlightId, text.isEmpty ? null : text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSavedHighlights() async {
    final dao = ref.read(readerHighlightDaoProvider);
    final highlights = await dao.watchByBookAndChapter(widget.bookId, _currentChapter).first;

    for (final hl in highlights) {
      final parts = _parseRange(hl.rangeStart, hl.rangeEnd);
      if (parts == null) continue;
      final c = hl.color;
      final colorHex = 'rgba(${(c >> 16) & 0xFF}, ${(c >> 8) & 0xFF}, ${c & 0xFF}, 0.4)';
      await _webViewController?.evaluateJavascript(
        source: jsApplyHighlight(
          id: hl.id,
          rangeStart: parts['startXPath']!,
          startOffset: int.parse(parts['startOffset']!),
          rangeEnd: parts['endXPath']!,
          endOffset: int.parse(parts['endOffset']!),
          colorHex: colorHex,
        ),
      );
    }
  }

  Map<String, String>? _parseRange(String rangeStart, String rangeEnd) {
    final startParts = rangeStart.split('|');
    final endParts = rangeEnd.split('|');
    if (startParts.length != 2 || endParts.length != 2) return null;
    return {
      'startXPath': startParts[0],
      'startOffset': startParts[1],
      'endXPath': endParts[0],
      'endOffset': endParts[1],
    };
  }

  Future<void> _updateCharacterSheet(String selectedText) async {
    final parser = StatParser();
    final parsed = parser.parse(selectedText);

    if (parsed.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stats found in selected text'), duration: Duration(seconds: 2)),
        );
      }
      return;
    }

    // Get or create a character sheet
    final dao = ref.read(characterSheetDaoProvider);
    final sheets = await dao.watchSheetsByBook(widget.bookId).first;

    CharacterSheet? targetSheet;

    if (sheets.isEmpty) {
      // Create a new sheet
      final name = parsed.characterName ?? 'Character';
      final id = await dao.insertSheet(CharacterSheetsCompanion(
        bookId: Value(widget.bookId),
        name: Value(name),
        level: parsed.level != null ? Value(parsed.level!) : const Value.absent(),
        className: parsed.className != null ? Value(parsed.className!) : const Value.absent(),
        lastUpdatedAt: Value(DateTime.now()),
      ));
      targetSheet = await dao.getSheetById(id);
    } else if (sheets.length == 1) {
      targetSheet = sheets.first;
    } else {
      // Let user pick which sheet to update
      if (!mounted) return;
      targetSheet = await showDialog<CharacterSheet>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Update which sheet?'),
          children: sheets.map((s) => SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, s),
            child: Text(s.name),
          )).toList(),
        ),
      );
    }

    if (targetSheet == null) return;

    // Update level/class if parsed
    if (parsed.level != null || parsed.className != null) {
      await dao.updateSheetMeta(
        targetSheet.id,
        level: parsed.level,
        className: parsed.className,
      );
    }

    // Upsert all parsed stats
    int count = 0;
    for (final stat in parsed.stats) {
      await dao.upsertEntry(targetSheet.id, stat.category, stat.key, stat.value);
      count++;
    }

    // Clear selection
    await _webViewController?.evaluateJavascript(source: 'window.getSelection().removeAllRanges();');
    _pendingSelection = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated ${targetSheet.name}: $count entries${parsed.level != null ? ', Lv.${parsed.level}' : ''}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => context.pushNamed('character_sheets', pathParameters: {'id': '${widget.bookId}'}),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _syncMindmap() async {
    if (_parsedEpub == null) return;

    // Get plain text of current chapter
    final htmlContent = await ref.read(epubServiceProvider).getChapterHtml(_parsedEpub!, _currentChapter);
    final plainText = _stripHtml(htmlContent);
    if (plainText.length < 50) return;

    // Get known entities
    final characters = await ref.read(characterRepositoryProvider).watchCharactersByBook(widget.bookId).first;
    final worldAreas = await ref.read(worldAreaRepositoryProvider).watchWorldAreasByBook(widget.bookId).first;

    if (characters.isEmpty && worldAreas.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add characters or world areas first to auto-update the mindmap'), duration: Duration(seconds: 3)),
        );
      }
      return;
    }

    final chapterLabel = 'Ch. ${_currentChapter + 1}';
    final extractor = EntityExtractor();
    final result = extractor.extract(
      text: plainText,
      characters: characters,
      worldAreas: worldAreas,
      chapterLabel: chapterLabel,
    );

    if (result.mentions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No known entities found in $chapterLabel'), duration: const Duration(seconds: 2)),
        );
      }
      return;
    }

    // Get current mindmap state
    final existingNodes = await ref.read(mindmapRepositoryProvider).watchNodesByBook(widget.bookId).first;
    final existingEdges = await ref.read(mindmapRepositoryProvider).watchEdgesByBook(widget.bookId).first;

    final updater = MindmapAutoUpdater();
    final plan = updater.planUpdate(
      extraction: result,
      existingNodes: existingNodes,
      existingEdges: existingEdges,
      bookId: widget.bookId,
    );

    final repo = ref.read(mindmapRepositoryProvider);

    // Create new nodes and collect their IDs
    final createdNodeIds = <String, int>{};
    for (final node in plan.newNodes) {
      final id = await repo.addNode(node);
      createdNodeIds[node.label] = id;
    }

    // Resolve edges that reference newly created nodes
    int edgesCreated = 0;
    for (final co in plan.coOccurrences) {
      final nodeAId = plan.mentionToNodeId[co.entityA.name] ?? createdNodeIds[co.entityA.name];
      final nodeBId = plan.mentionToNodeId[co.entityB.name] ?? createdNodeIds[co.entityB.name];
      if (nodeAId != null && nodeBId != null && nodeAId != nodeBId) {
        // Check if edge already exists
        final allEdges = await repo.watchEdgesByBook(widget.bookId).first;
        final exists = allEdges.any((e) =>
          (e.fromNodeId == nodeAId && e.toNodeId == nodeBId) ||
          (e.fromNodeId == nodeBId && e.toNodeId == nodeAId));
        if (!exists) {
          await repo.addEdge(domain_edge.MindmapEdge(
            bookId: widget.bookId,
            fromNodeId: nodeAId,
            toNodeId: nodeBId,
            label: chapterLabel,
          ));
          edgesCreated++;
        }
      }
    }

    if (mounted) {
      final mentionNames = result.mentions.map((m) => m.name).take(4).join(', ');
      final extra = result.mentions.length > 4 ? ' +${result.mentions.length - 4} more' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$chapterLabel: found $mentionNames$extra'
              '${plan.newNodes.isNotEmpty ? ', +${plan.newNodes.length} nodes' : ''}'
              '${edgesCreated > 0 ? ', +$edgesCreated edges' : ''}'),
          action: SnackBarAction(
            label: 'Mindmap',
            onPressed: () => context.pushNamed('mindmap', pathParameters: {'id': '${widget.bookId}'}),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _addBookmark() async {
    final chapterTitle = _getChapterTitle();
    final dao = ref.read(readerBookmarkDaoProvider);
    await dao.insertBookmark(ReaderBookmarksCompanion(
      bookId: Value(widget.bookId),
      chapterIndex: Value(_currentChapter),
      scrollPosition: Value(_currentScroll),
      chapterTitle: Value(chapterTitle),
      createdAt: Value(DateTime.now()),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bookmarked: $chapterTitle'), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reader')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final chapterTitle = _getChapterTitle();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapterTitle,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Chapter ${_currentChapter + 1} of ${_parsedEpub!.totalChapters}',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.hub_outlined),
            tooltip: 'Sync Mindmap',
            onPressed: _syncMindmap,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Add bookmark',
            onPressed: _addBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Bookmarks',
            onPressed: () => setState(() {
              _bookmarksOpen = !_bookmarksOpen;
              _tocOpen = false;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Table of Contents',
            onPressed: () => setState(() {
              _tocOpen = !_tocOpen;
              _bookmarksOpen = false;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Reader settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView reader
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              allowFileAccess: true,
              javaScriptEnabled: true,
              supportZoom: false,
              verticalScrollBarEnabled: false,
              disableHorizontalScroll: true,
            ),
            onWebViewCreated: (controller) async {
              _webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: 'onScroll',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final pos = (args[0] as num).toDouble().clamp(0.0, 1.0);
                    _currentScroll = pos;
                    _debounceSave();
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'onTextSelected',
                callback: (args) {
                  if (args.isNotEmpty && mounted) {
                    try {
                      final data = jsonDecode(args[0] as String) as Map<String, dynamic>;
                      _onTextSelected(data);
                    } catch (_) {}
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'onHighlightTap',
                callback: (args) {
                  if (args.isNotEmpty && mounted) {
                    final id = int.tryParse(args[0].toString());
                    if (id != null) _onHighlightTap(id);
                  }
                },
              );

              // Load the initial chapter
              await _loadChapter(_currentChapter);
            },
            onLoadStop: (controller, url) async {
              // Restore scroll position after chapter loads
              if (_currentScroll > 0.01) {
                await Future.delayed(const Duration(milliseconds: 200));
                await controller.evaluateJavascript(source: '''
                  var maxScroll = document.documentElement.scrollHeight - window.innerHeight;
                  window.scrollTo(0, maxScroll * $_currentScroll);
                ''');
              }
              // Re-apply saved highlights for this chapter
              await Future.delayed(const Duration(milliseconds: 100));
              await _loadSavedHighlights();
            },
          ),

          // TOC overlay
          if (_tocOpen) _buildTocDrawer(colorScheme),
          // Bookmarks overlay
          if (_bookmarksOpen) _buildBookmarksDrawer(colorScheme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(colorScheme),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReaderSettingsSheet(
        epubData: _epubData!.copyWith(
          fontSize: _fontSize,
          fontFamily: _fontFamily,
          readerTheme: _readerTheme,
          lineHeight: _lineHeight,
        ),
        onChanged: _onSettingsChanged,
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    final total = _parsedEpub?.totalChapters ?? 1;
    final progress = total > 0 ? (_currentChapter + 1) / total : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentChapter > 0
                        ? () => _loadChapter(_currentChapter - 1)
                        : null,
                    tooltip: 'Previous chapter',
                  ),
                  Expanded(
                    child: Slider(
                      value: _currentChapter.toDouble(),
                      min: 0,
                      max: (total - 1).toDouble().clamp(0, double.infinity),
                      divisions: total > 1 ? total - 1 : null,
                      onChanged: (v) => _loadChapter(v.round()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentChapter < total - 1
                        ? () => _loadChapter(_currentChapter + 1)
                        : null,
                    tooltip: 'Next chapter',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksDrawer(ColorScheme colorScheme) {
    final bookmarksAsync = ref.watch(readerBookmarksByBookProvider(widget.bookId));

    return GestureDetector(
      onTap: () => setState(() => _bookmarksOpen = false),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              color: colorScheme.surface,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bookmarks, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Bookmarks', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  Expanded(
                    child: bookmarksAsync.when(
                      data: (bookmarks) {
                        if (bookmarks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_border, size: 40, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 8),
                                Text(
                                  'No bookmarks yet.\nTap the bookmark icon to add one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: bookmarks.length,
                          itemBuilder: (context, i) {
                            final bm = bookmarks[i];
                            final dateStr = DateFormat.yMMMd().add_jm().format(bm.createdAt);
                            return ListTile(
                              dense: true,
                              leading: Icon(Icons.bookmark, color: colorScheme.primary, size: 20),
                              title: Text(
                                bm.chapterTitle ?? 'Chapter ${bm.chapterIndex + 1}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(dateStr, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                                onPressed: () {
                                  ref.read(readerBookmarkDaoProvider).deleteBookmark(bm.id!);
                                },
                              ),
                              onTap: () {
                                _currentScroll = bm.scrollPosition;
                                _loadChapter(bm.chapterIndex);
                                setState(() => _bookmarksOpen = false);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTocDrawer(ColorScheme colorScheme) {
    final toc = _parsedEpub?.tableOfContents ?? [];

    return GestureDetector(
      onTap: () => setState(() => _tocOpen = false),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              color: colorScheme.surface,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Table of Contents', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  Expanded(
                    child: toc.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.menu_book, size: 40, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 8),
                                Text(
                                  'No TOC available.\nUse the slider to navigate.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: toc.length,
                            itemBuilder: (context, i) => _buildTocItem(toc[i], colorScheme),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTocItem(EpubChapter chapter, ColorScheme colorScheme) {
    final spineIndex = _parsedEpub?.spineFiles.indexWhere(
      (f) => f.contains(chapter.htmlFileName) || chapter.htmlFileName.contains(f),
    ) ?? -1;
    final isCurrent = spineIndex == _currentChapter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          selected: isCurrent,
          selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
          title: Text(
            chapter.title,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? colorScheme.primary : null,
            ),
          ),
          onTap: spineIndex >= 0
              ? () {
                  _loadChapter(spineIndex);
                  setState(() => _tocOpen = false);
                }
              : null,
        ),
        if (chapter.subChapters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: chapter.subChapters.map((sub) => _buildTocItem(sub, colorScheme)).toList(),
            ),
          ),
      ],
    );
  }

  String _getChapterTitle() {
    if (_parsedEpub == null) return 'Reader';

    final currentFile = _parsedEpub!.spineFiles[_currentChapter];
    for (final ch in _parsedEpub!.tableOfContents) {
      if (currentFile.contains(ch.htmlFileName) || ch.htmlFileName.contains(currentFile)) {
        return ch.title;
      }
      for (final sub in ch.subChapters) {
        if (currentFile.contains(sub.htmlFileName) || sub.htmlFileName.contains(currentFile)) {
          return sub.title;
        }
      }
    }

    return _parsedEpub!.title;
  }
}
