import '../../domain/models/character.dart';
import '../../domain/models/world_area.dart';

enum ParsedEntityType { character, worldArea }

class ParsedEntity {
  final String name;
  final ParsedEntityType type;
  final bool isNew;
  final int? existingId;
  final String? description;

  const ParsedEntity({
    required this.name,
    required this.type,
    required this.isNew,
    this.existingId,
    this.description,
  });

  @override
  String toString() => '${isNew ? "NEW" : "EXISTING"} ${type.name}: $name${description != null ? ' ($description)' : ''}';
}

class ParsedConnection {
  final String fromName;
  final String toName;
  final String label;

  const ParsedConnection({
    required this.fromName,
    required this.toName,
    required this.label,
  });

  @override
  String toString() => '$fromName --[$label]--> $toName';
}

class QuickAddResult {
  final List<ParsedEntity> entities;
  final List<ParsedConnection> connections;
  final List<String> warnings;

  const QuickAddResult({
    required this.entities,
    required this.connections,
    this.warnings = const [],
  });
}

class QuickAddParser {
  final List<Character> existingCharacters;
  final List<WorldArea> existingWorldAreas;

  QuickAddParser({
    required this.existingCharacters,
    required this.existingWorldAreas,
  });

  // Regex: "Name (new char)" or "Name(new wa)" with optional extras after dash/comma
  // e.g. "Tom (new char - shade)" or "Adventure Guild(new wa)"
  static final _taggedEntityRe = RegExp(
    r'([A-Z][\w\s]*?)\s*\(\s*(?:new\s+)(char(?:acter)?|wa|world\s*area)(?:\s*[-,]\s*(.+?))?\s*\)',
    caseSensitive: false,
  );

  QuickAddResult parse(String input) {
    final entityMap = <String, ParsedEntity>{}; // name lowercase -> entity
    final connections = <ParsedConnection>[];
    final warnings = <String>[];

    final lines = input.split('\n').where((l) => l.trim().isNotEmpty).toList();

    for (final line in lines) {
      _parseLine(line, entityMap, connections, warnings);
    }

    return QuickAddResult(
      entities: entityMap.values.toList(),
      connections: connections,
      warnings: warnings,
    );
  }

  void _parseLine(
    String line,
    Map<String, ParsedEntity> entityMap,
    List<ParsedConnection> connections,
    List<String> warnings,
  ) {
    // 1. Extract all tagged entities (new char/wa) and replace them with placeholders
    final taggedSpans = <_Span>[];
    for (final match in _taggedEntityRe.allMatches(line)) {
      final rawName = match.group(1)!.trim();
      final rawType = match.group(2)!.toLowerCase().trim();
      final extra = match.group(3)?.trim();

      final type = (rawType.startsWith('char'))
          ? ParsedEntityType.character
          : ParsedEntityType.worldArea;

      final key = rawName.toLowerCase();
      if (!entityMap.containsKey(key)) {
        entityMap[key] = ParsedEntity(
          name: rawName,
          type: type,
          isNew: true,
          description: extra,
        );
      }

      taggedSpans.add(_Span(start: match.start, end: match.end, name: rawName));
    }

    // 2. Build a version of the line with tagged entities replaced by sentinel tokens
    var processed = line;
    final entityMentions = <String>[]; // ordered entity names found in this line

    // Replace tagged spans in reverse order to preserve indices
    for (final span in taggedSpans.reversed) {
      processed = processed.substring(0, span.start) +
          '<<${span.name}>>' +
          processed.substring(span.end);
    }

    // 3. Find existing entity references (untagged names that match DB)
    // Sort by name length descending so longer names match first
    final allKnown = <String, ParsedEntity>{};
    for (final c in existingCharacters) {
      allKnown[c.name.toLowerCase()] = ParsedEntity(
        name: c.name,
        type: ParsedEntityType.character,
        isNew: false,
        existingId: c.id,
      );
    }
    for (final a in existingWorldAreas) {
      allKnown[a.name.toLowerCase()] = ParsedEntity(
        name: a.name,
        type: ParsedEntityType.worldArea,
        isNew: false,
        existingId: a.id,
      );
    }

    // Also include already-parsed new entities for cross-line references
    for (final entry in entityMap.entries) {
      if (!allKnown.containsKey(entry.key)) {
        allKnown[entry.key] = entry.value;
      }
    }

    final sortedKnown = allKnown.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    // Find untagged mentions of known entities
    var searchable = processed.toLowerCase();
    for (final entry in sortedKnown) {
      final nameKey = entry.key;
      var idx = searchable.indexOf(nameKey);
      while (idx != -1) {
        // Check it's not inside a <<...>> placeholder
        final before = processed.substring(0, idx);
        final openCount = '<<'.allMatches(before).length;
        final closeCount = '>>'.allMatches(before).length;
        if (openCount == closeCount) {
          // Valid untagged mention — replace with sentinel
          final originalName = entry.value.name;
          entityMap.putIfAbsent(nameKey, () => entry.value);
          processed = processed.substring(0, idx) +
              '<<$originalName>>' +
              processed.substring(idx + nameKey.length);
          searchable = processed.toLowerCase();
        }
        idx = searchable.indexOf(nameKey, idx + nameKey.length + 4);
      }
    }

    // 4. Extract ordered entity mentions from sentinels
    final mentionRe = RegExp(r'<<(.+?)>>');
    final mentions = mentionRe.allMatches(processed).map((m) => m.group(1)!).toList();

    // 5. Extract connection labels from text between consecutive entity pairs
    if (mentions.length >= 2) {
      for (var i = 0; i < mentions.length - 1; i++) {
        final from = mentions[i];
        final to = mentions[i + 1];

        final fromSentinel = '<<$from>>';
        final toSentinel = '<<$to>>';
        final fromIdx = processed.indexOf(fromSentinel);
        final toIdx = processed.indexOf(toSentinel, fromIdx + fromSentinel.length);

        if (fromIdx >= 0 && toIdx >= 0) {
          var between = processed
              .substring(fromIdx + fromSentinel.length, toIdx)
              .trim();

          // Clean up common filler words
          between = _cleanLabel(between);

          if (between.isNotEmpty) {
            connections.add(ParsedConnection(
              fromName: from,
              toName: to,
              label: between,
            ));
          }
        }
      }
    }

    // 6. Look for "association" pattern: "Name (new char - association - label)"
    // Already captured via the extra group — generate connection if context entity exists
    for (final match in _taggedEntityRe.allMatches(line)) {
      final rawName = match.group(1)!.trim();
      final extra = match.group(3)?.trim();
      if (extra == null) continue;

      // Check if extra contains an association keyword
      final parts = extra.split(RegExp(r'\s*[-,]\s*'));
      if (parts.length >= 2) {
        final keyword = parts[0].toLowerCase();
        if (keyword == 'association' || keyword == 'role' || keyword == 'relation') {
          final label = parts.sublist(1).join(', ');
          // Find the other entity mentioned on this line (before this one)
          final otherMentions = mentions.where((m) => m.toLowerCase() != rawName.toLowerCase()).toList();
          if (otherMentions.isNotEmpty) {
            connections.add(ParsedConnection(
              fromName: rawName,
              toName: otherMentions.last,
              label: label,
            ));
          }
        }
      }
    }
  }

  static String _cleanLabel(String text) {
    // Remove leading/trailing conjunctions, articles, pronouns
    var s = text
        .replaceAll(RegExp(r'\band\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bthe\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\ba\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\ban\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bhe\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bshe\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\balso\b', caseSensitive: false), '')
        .trim();

    // Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove trailing/leading punctuation
    s = s.replaceAll(RegExp(r'^[,.\-;:]+|[,.\-;:]+$'), '').trim();

    return s;
  }
}

class _Span {
  final int start;
  final int end;
  final String name;
  const _Span({required this.start, required this.end, required this.name});
}
