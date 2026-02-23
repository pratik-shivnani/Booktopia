import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/epub_service.dart';
import '../../domain/models/epub_data.dart';
import '../../providers/providers.dart';

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
  Timer? _saveTimer;
  double _currentScroll = 0.0;

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

  String _wrapWithReaderStyles(String html) {
    // Inject reader-friendly CSS
    const readerCss = '''
    <style id="booktopia-reader-style">
      body {
        font-family: 'Georgia', 'Noto Serif', serif;
        font-size: 18px;
        line-height: 1.7;
        color: #222;
        background: #FAFAFA;
        padding: 16px 20px 80px 20px;
        margin: 0;
        word-wrap: break-word;
        overflow-wrap: break-word;
        -webkit-text-size-adjust: 100%;
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
        color: #6750A4;
      }
    </style>
    <script>
      window.addEventListener('scroll', function() {
        var scrollPos = window.scrollY / (document.documentElement.scrollHeight - window.innerHeight);
        if (isNaN(scrollPos)) scrollPos = 0;
        window.flutter_inappwebview.callHandler('onScroll', scrollPos);
      });
    </script>
    ''';

    // Inject before </head> or at the start
    if (html.contains('</head>')) {
      return html.replaceFirst('</head>', '$readerCss</head>');
    } else if (html.contains('<body')) {
      return html.replaceFirst('<body', '$readerCss<body');
    } else {
      return '<html><head>$readerCss</head><body>$html</body></html>';
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
            icon: const Icon(Icons.list),
            tooltip: 'Table of Contents',
            onPressed: () => setState(() => _tocOpen = !_tocOpen),
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

              // Load the initial chapter
              await _loadChapter(_currentChapter);
            },
            onLoadStop: (controller, url) async {
              // Restore scroll position after chapter loads
              if (_currentScroll > 0.01) {
                await Future.delayed(const Duration(milliseconds: 200));
                await controller.evaluateJavascript(source: '''
                  var maxScroll = document.documentElement.scrollHeight - window.innerHeight;
                  window.scrollTo(0, maxScroll * ${_currentScroll});
                ''');
              }
            },
          ),

          // TOC overlay
          if (_tocOpen) _buildTocDrawer(colorScheme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(colorScheme),
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
            // Progress bar
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
    // Find the spine index for this chapter file
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

    // Try to find the TOC entry for the current chapter
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
