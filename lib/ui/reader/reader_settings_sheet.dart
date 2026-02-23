import 'package:flutter/material.dart';

import '../../domain/models/epub_data.dart';

class ReaderSettingsSheet extends StatefulWidget {
  final EpubData epubData;
  final void Function(EpubData updated) onChanged;

  const ReaderSettingsSheet({
    super.key,
    required this.epubData,
    required this.onChanged,
  });

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  late int _fontSize;
  late String _fontFamily;
  late ReaderTheme _theme;
  late double _lineHeight;

  static const _fonts = [
    _FontOption('serif', 'Serif (Georgia)', 'Georgia, serif'),
    _FontOption('sans-serif', 'Sans-serif', '-apple-system, Helvetica, Arial, sans-serif'),
    _FontOption('monospace', 'Monospace', 'Courier New, monospace'),
    _FontOption('system-ui', 'System', 'system-ui, sans-serif'),
  ];

  @override
  void initState() {
    super.initState();
    _fontSize = widget.epubData.fontSize;
    _fontFamily = widget.epubData.fontFamily;
    _theme = widget.epubData.readerTheme;
    _lineHeight = widget.epubData.lineHeight;
  }

  void _emit() {
    widget.onChanged(widget.epubData.copyWith(
      fontSize: _fontSize,
      fontFamily: _fontFamily,
      readerTheme: _theme,
      lineHeight: _lineHeight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
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

          Text('Reader Settings', style: textTheme.titleLarge),
          const SizedBox(height: 20),

          // Theme selection
          Text('Theme', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: ReaderTheme.values.map((t) {
              final selected = _theme == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _theme = t);
                    _emit();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _themePreviewBg(t),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? colorScheme.primary : colorScheme.outlineVariant,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Aa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _themePreviewFg(t),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: _themePreviewFg(t).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Font size
          Row(
            children: [
              Text('Font Size', style: textTheme.titleSmall),
              const Spacer(),
              Text('$_fontSize px', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.text_decrease),
                onPressed: _fontSize > 12
                    ? () {
                        setState(() => _fontSize--);
                        _emit();
                      }
                    : null,
              ),
              Expanded(
                child: Slider(
                  value: _fontSize.toDouble(),
                  min: 12,
                  max: 32,
                  divisions: 20,
                  onChanged: (v) {
                    setState(() => _fontSize = v.round());
                    _emit();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase),
                onPressed: _fontSize < 32
                    ? () {
                        setState(() => _fontSize++);
                        _emit();
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Line height
          Row(
            children: [
              Text('Line Spacing', style: textTheme.titleSmall),
              const Spacer(),
              Text('${_lineHeight.toStringAsFixed(1)}x', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Slider(
            value: _lineHeight,
            min: 1.0,
            max: 3.0,
            divisions: 20,
            onChanged: (v) {
              setState(() => _lineHeight = double.parse(v.toStringAsFixed(1)));
              _emit();
            },
          ),
          const SizedBox(height: 12),

          // Font family
          Text('Font', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fonts.map((f) {
              final selected = _fontFamily == f.key;
              return ChoiceChip(
                label: Text(f.displayName),
                selected: selected,
                onSelected: (_) {
                  setState(() => _fontFamily = f.key);
                  _emit();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _themePreviewBg(ReaderTheme t) {
    switch (t) {
      case ReaderTheme.light:
        return const Color(0xFFFAFAFA);
      case ReaderTheme.dark:
        return const Color(0xFF1A1A1A);
      case ReaderTheme.sepia:
        return const Color(0xFFF5E6C8);
    }
  }

  Color _themePreviewFg(ReaderTheme t) {
    switch (t) {
      case ReaderTheme.light:
        return const Color(0xFF222222);
      case ReaderTheme.dark:
        return const Color(0xFFCCCCCC);
      case ReaderTheme.sepia:
        return const Color(0xFF5B4636);
    }
  }
}

class _FontOption {
  final String key;
  final String displayName;
  final String cssValue;

  const _FontOption(this.key, this.displayName, this.cssValue);
}
