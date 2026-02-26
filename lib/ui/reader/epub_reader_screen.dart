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
import '../../domain/models/character.dart' as domain_character;
import '../../domain/models/mindmap_edge.dart' as domain_edge;
import '../../domain/models/mindmap_node.dart' as domain_node;
import '../../domain/models/world_area.dart' as domain_worldarea;
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

  // Floating selection toolbar overlay (renders above platform views)
  OverlayEntry? _toolbarOverlay;
  DateTime? _toolbarShownAt;

  // Reader settings (kept in sync with DB)
  int _fontSize = 18;
  String _fontFamily = 'serif';
  ReaderTheme _readerTheme = ReaderTheme.light;
  double _lineHeight = 1.7;

  // Immersive mode — hides app bar + bottom bar on tap
  bool _immersive = false;

  // Auto-scroll
  bool _autoScrollActive = false;
  double _autoScrollSpeed = 1.5; // pixels per tick (50ms interval)
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  @override
  void dispose() {
    _toolbarOverlay?.remove();
    _toolbarOverlay = null;
    _saveTimer?.cancel();
    _stopAutoScroll();
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
        return 'color: #CCCCCC !important; background: #1A1A1A !important;';
      case ReaderTheme.sepia:
        return 'color: #5B4636 !important; background: #F5E6C8 !important;';
      case ReaderTheme.light:
      default:
        return 'color: #222222 !important; background: #FAFAFA !important;';
    }
  }

  Color _scaffoldBgColor() {
    switch (_readerTheme) {
      case ReaderTheme.dark:
        return const Color(0xFF1A1A1A);
      case ReaderTheme.sepia:
        return const Color(0xFFF5E6C8);
      case ReaderTheme.light:
      default:
        return const Color(0xFFFAFAFA);
    }
  }

  Color _scaffoldFgColor() {
    switch (_readerTheme) {
      case ReaderTheme.dark:
        return const Color(0xFFCCCCCC);
      case ReaderTheme.sepia:
        return const Color(0xFF5B4636);
      case ReaderTheme.light:
      default:
        return const Color(0xFF222222);
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
      * {
        font-family: ${_cssFontStack()} !important;
        font-size: inherit !important;
        line-height: inherit !important;
      }
      body {
        font-family: ${_cssFontStack()} !important;
        font-size: ${_fontSize}px !important;
        line-height: ${_lineHeight}em !important;
        ${_cssColors()}
        padding: 24px 24px 80px 24px !important;
        margin: 0 !important;
        word-wrap: break-word !important;
        overflow-wrap: break-word !important;
        -webkit-text-size-adjust: none !important;
        text-size-adjust: none !important;
        text-align: justify !important;
      }
      img {
        max-width: 100% !important;
        height: auto !important;
      }
      h1, h2, h3, h4, h5, h6 {
        font-size: 1.2em !important;
        line-height: 1.3 !important;
        margin-top: 1.2em !important;
        text-align: left !important;
      }
      p {
        margin-bottom: 0.6em !important;
        margin-top: 0 !important;
        text-indent: 0 !important;
      }
      a {
        color: ${_cssLinkColor()} !important;
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
      // Tap in empty area to toggle immersive mode
      document.addEventListener('click', function(e) {
        var sel = window.getSelection();
        if (sel && !sel.isCollapsed) return;
        if (e.target.closest && e.target.closest('.booktopia-highlight')) return;
        window.flutter_inappwebview.callHandler('onTapContent');
      });
      // Swipe detection for auto-scroll cancel
      var _touchStartX = 0, _touchStartY = 0;
      document.addEventListener('touchstart', function(e) {
        _touchStartX = e.touches[0].clientX;
        _touchStartY = e.touches[0].clientY;
      });
      document.addEventListener('touchend', function(e) {
        var dx = e.changedTouches[0].clientX - _touchStartX;
        var dy = e.changedTouches[0].clientY - _touchStartY;
        if (Math.abs(dx) > 80 && Math.abs(dx) > Math.abs(dy) * 1.5) {
          window.flutter_inappwebview.callHandler('onSwipeHorizontal', dx > 0 ? 'right' : 'left');
        }
      });
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

  // --- Auto-scroll ---

  void _startAutoScroll() {
    if (_autoScrollActive) return;
    setState(() => _autoScrollActive = true);
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _webViewController?.evaluateJavascript(
        source: 'window.scrollBy(0, $_autoScrollSpeed);',
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    if (_autoScrollActive && mounted) {
      setState(() => _autoScrollActive = false);
    }
    _autoScrollActive = false;
  }

  void _adjustAutoScrollSpeed(double delta) {
    setState(() {
      _autoScrollSpeed = (_autoScrollSpeed + delta).clamp(0.3, 8.0);
    });
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

    // Position the floating toolbar near the selection
    final rectTop = (selectionData['rectTop'] as num?)?.toDouble() ?? 0;
    final rectBottom = (selectionData['rectBottom'] as num?)?.toDouble() ?? 0;
    final rectLeft = (selectionData['rectLeft'] as num?)?.toDouble() ?? 0;
    final rectRight = (selectionData['rectRight'] as num?)?.toDouble() ?? 0;

    // Account for app bar height (~kToolbarHeight + statusBar)
    final appBarOffset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Place toolbar above the selection, centered horizontally
    const toolbarHeight = 52.0;
    const toolbarWidth = 280.0;
    double top = rectTop + appBarOffset - toolbarHeight - 8;
    if (top < appBarOffset + 4) {
      // Not enough room above, place below selection
      top = rectBottom + appBarOffset + 8;
    }
    // Clamp to screen bounds
    top = top.clamp(appBarOffset + 4, screenHeight - toolbarHeight - 80);
    double left = ((rectLeft + rectRight) / 2) - (toolbarWidth / 2);
    left = left.clamp(8.0, screenWidth - toolbarWidth - 8);

    _toolbarShownAt = DateTime.now();
    _showToolbarOverlay(top, left);
  }

  void _showToolbarOverlay(double top, double left) {
    // Remove previous overlay if any
    _toolbarOverlay?.remove();
    _toolbarOverlay = null;

    final selectedText = _pendingSelection?['text'] as String? ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    _toolbarOverlay = OverlayEntry(
      builder: (_) => Positioned(
        top: top,
        left: left,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainer,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color circles for quick highlight
                ..._highlightColors.take(4).map((c) => _ToolbarColorDot(
                  color: Color(c),
                  onTap: () {
                    _dismissSelectionToolbar();
                    _createHighlight(c);
                  },
                )),
                _ToolbarDivider(color: colorScheme.outlineVariant),
                // Note button
                _ToolbarIconButton(
                  icon: Icons.note_add,
                  tooltip: 'Note',
                  iconColor: colorScheme.onSurfaceVariant,
                  onTap: () {
                    _dismissSelectionToolbar();
                    _createHighlightWithNote();
                  },
                ),
                // Character sheet button
                _ToolbarIconButton(
                  icon: Icons.person_search,
                  tooltip: 'Stats',
                  iconColor: colorScheme.onSurfaceVariant,
                  onTap: () {
                    _dismissSelectionToolbar();
                    _updateCharacterSheet(selectedText);
                  },
                ),
                _ToolbarDivider(color: colorScheme.outlineVariant),
                // Add as Character
                _ToolbarIconButton(
                  icon: Icons.person_add,
                  tooltip: 'Add Character',
                  iconColor: colorScheme.onSurfaceVariant,
                  onTap: () {
                    _dismissSelectionToolbar();
                    _addSelectionAsCharacter(selectedText);
                  },
                ),
                // Add as World Area
                _ToolbarIconButton(
                  icon: Icons.map_outlined,
                  tooltip: 'Add World Area',
                  iconColor: colorScheme.onSurfaceVariant,
                  onTap: () {
                    _dismissSelectionToolbar();
                    _addSelectionAsWorldArea(selectedText);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_toolbarOverlay!);
  }

  void _dismissSelectionToolbar() {
    // Guard: don't dismiss within 800ms of showing (mobile fires rapid selectionchange events)
    if (_toolbarOverlay != null &&
        _toolbarShownAt != null &&
        DateTime.now().difference(_toolbarShownAt!).inMilliseconds < 800) {
      return;
    }
    _toolbarOverlay?.remove();
    _toolbarOverlay = null;
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

  Future<void> _addSelectionAsCharacter(String selectedText) async {
    final name = selectedText.trim().split('\n').first.trim();
    if (name.isEmpty || name.length > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a character name'), duration: Duration(seconds: 2)),
        );
      }
      return;
    }

    // Check for duplicates
    final existing = await ref.read(characterRepositoryProvider).watchCharactersByBook(widget.bookId).first;
    if (existing.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" already exists as a character'), duration: const Duration(seconds: 2)),
        );
      }
      return;
    }

    await ref.read(characterRepositoryProvider).addCharacter(
      domain_character.Character(bookId: widget.bookId, name: name),
    );
    await _webViewController?.evaluateJavascript(source: 'window.getSelection().removeAllRanges();');
    _pendingSelection = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added character: $name'),
          action: SnackBarAction(
            label: 'Mindmap',
            onPressed: () => context.pushNamed('mindmap', pathParameters: {'id': '${widget.bookId}'}),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _addSelectionAsWorldArea(String selectedText) async {
    final name = selectedText.trim().split('\n').first.trim();
    if (name.isEmpty || name.length > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a location name'), duration: Duration(seconds: 2)),
        );
      }
      return;
    }

    // Check for duplicates
    final existing = await ref.read(worldAreaRepositoryProvider).watchWorldAreasByBook(widget.bookId).first;
    if (existing.any((w) => w.name.toLowerCase() == name.toLowerCase())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" already exists as a world area'), duration: const Duration(seconds: 2)),
        );
      }
      return;
    }

    await ref.read(worldAreaRepositoryProvider).addWorldArea(
      domain_worldarea.WorldArea(bookId: widget.bookId, name: name),
    );
    await _webViewController?.evaluateJavascript(source: 'window.getSelection().removeAllRanges();');
    _pendingSelection = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added world area: $name'),
          action: SnackBarAction(
            label: 'Mindmap',
            onPressed: () => context.pushNamed('mindmap', pathParameters: {'id': '${widget.bookId}'}),
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
    final total = _parsedEpub?.totalChapters ?? 1;
    final bookProgress = total > 0 ? ((_currentChapter + _currentScroll) / total * 100) : 0.0;
    final bgColor = _scaffoldBgColor();
    final fgColor = _scaffoldFgColor();
    final fgDim = fgColor.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: _immersive
          ? null
          : AppBar(
              backgroundColor: bgColor.withValues(alpha: 0.95),
              foregroundColor: fgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapterTitle,
                    style: TextStyle(fontSize: 14, color: fgColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Chapter ${_currentChapter + 1} of $total',
                    style: TextStyle(fontSize: 11, color: fgDim),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(_autoScrollActive ? Icons.stop_circle_outlined : Icons.slow_motion_video),
                  tooltip: _autoScrollActive ? 'Stop auto-scroll' : 'Auto-scroll',
                  onPressed: _autoScrollActive ? _stopAutoScroll : _startAutoScroll,
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Character Sheet',
                  onPressed: () => context.pushNamed('characterSheets', pathParameters: {'id': '${widget.bookId}'}),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'Add bookmark',
                  onPressed: _addBookmark,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More',
                  onSelected: (value) {
                    switch (value) {
                      case 'mindmap':
                        _syncMindmap();
                      case 'bookmarks':
                        setState(() { _bookmarksOpen = !_bookmarksOpen; _tocOpen = false; });
                      case 'toc':
                        setState(() { _tocOpen = !_tocOpen; _bookmarksOpen = false; });
                      case 'settings':
                        _showSettings();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'toc', child: ListTile(leading: Icon(Icons.list), title: Text('Table of Contents'), dense: true, contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'bookmarks', child: ListTile(leading: Icon(Icons.bookmarks_outlined), title: Text('Bookmarks'), dense: true, contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'mindmap', child: ListTile(leading: Icon(Icons.hub_outlined), title: Text('Sync Mindmap'), dense: true, contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Reader Settings'), dense: true, contentPadding: EdgeInsets.zero)),
                  ],
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
                    // Update progress in bottom bar
                    if (mounted) setState(() {});
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
                handlerName: 'onSelectionDismissed',
                callback: (args) {
                  if (mounted) _dismissSelectionToolbar();
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

              controller.addJavaScriptHandler(
                handlerName: 'onTapContent',
                callback: (args) {
                  if (!mounted) return;
                  if (_autoScrollActive) {
                    _stopAutoScroll();
                  } else {
                    setState(() {
                      _immersive = !_immersive;
                      _tocOpen = false;
                      _bookmarksOpen = false;
                    });
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'onSwipeHorizontal',
                callback: (args) {
                  if (_autoScrollActive && mounted) {
                    _stopAutoScroll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Auto-scroll cancelled'), duration: Duration(seconds: 1)),
                    );
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
          // Auto-scroll speed overlay
          if (_autoScrollActive) _buildAutoScrollOverlay(bgColor, fgColor, fgDim),
        ],
      ),
      bottomNavigationBar: _immersive
          ? null
          : _buildBottomBar(bgColor, fgColor, fgDim, chapterTitle, bookProgress),
    );
  }

  Widget _buildAutoScrollOverlay(Color bgColor, Color fgColor, Color fgDim) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: fgColor.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed, size: 18, color: fgDim),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _adjustAutoScrollSpeed(-0.3),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fgColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.remove, size: 18, color: fgColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${_autoScrollSpeed.toStringAsFixed(1)}x',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fgColor),
                ),
              ),
              GestureDetector(
                onTap: () => _adjustAutoScrollSpeed(0.3),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fgColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.add, size: 18, color: fgColor),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _stopAutoScroll,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildBottomBar(Color bgColor, Color fgColor, Color fgDim, String chapterTitle, double bookProgress) {
    final total = _parsedEpub?.totalChapters ?? 1;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chapter navigation row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: fgColor),
                    onPressed: _currentChapter > 0
                        ? () => _loadChapter(_currentChapter - 1)
                        : null,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Previous chapter',
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: fgColor.withValues(alpha: 0.4),
                        inactiveTrackColor: fgColor.withValues(alpha: 0.15),
                        thumbColor: fgColor.withValues(alpha: 0.6),
                        overlayColor: fgColor.withValues(alpha: 0.1),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _currentChapter.toDouble(),
                        min: 0,
                        max: (total - 1).toDouble().clamp(0, double.infinity),
                        divisions: total > 1 ? total - 1 : null,
                        onChanged: (v) => _loadChapter(v.round()),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: fgColor),
                    onPressed: _currentChapter < total - 1
                        ? () => _loadChapter(_currentChapter + 1)
                        : null,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Next chapter',
                  ),
                ],
              ),
            ),
            // Progress info row (Moon+ style)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ch${_currentChapter + 1}/$total \u00B7 $chapterTitle',
                      style: TextStyle(fontSize: 11, color: fgDim),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bookProgress.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 11, color: fgDim, fontWeight: FontWeight.w600),
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

// ─── Compact toolbar widgets ─────────────────────────────────────

class _ToolbarColorDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _ToolbarColorDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;
  const _ToolbarIconButton({required this.icon, required this.tooltip, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  final Color? color;
  const _ToolbarDivider({this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: (color ?? Theme.of(context).colorScheme.outlineVariant).withValues(alpha: 0.4),
    );
  }
}
