/// Parses LitRPG character stat blocks from selected text.
///
/// Handles common formats:
/// - `Level: 47`, `Lv. 47`, `LVL 47`
/// - `Class: Necromancer`, `Job: Swordsman`
/// - `HP: 1200/1200`, `Health: 500`, `MP: 3400`
/// - `STR: 45`, `Strength: 45`, `STR 45`
/// - `[Skill Name (Lvl 8)]`, `Skill Name - Level 8`
/// - `Race: Human`, `Title: Dragon Slayer`

/// Categories matching CharacterSheetEntries.category column.
class SheetCategory {
  static const int stat = 0;
  static const int skill = 1;
  static const int ability = 2;
  static const int resource = 3;
  static const int custom = 4;
}

class ParsedStat {
  final String key;
  final String value;
  final int category;

  const ParsedStat({required this.key, required this.value, required this.category});

  @override
  String toString() => '[$_categoryLabel] $key: $value';

  String get _categoryLabel {
    switch (category) {
      case SheetCategory.stat: return 'Stat';
      case SheetCategory.skill: return 'Skill';
      case SheetCategory.ability: return 'Ability';
      case SheetCategory.resource: return 'Resource';
      case SheetCategory.custom: return 'Info';
      default: return '?';
    }
  }
}

class ParsedSheetData {
  final String? characterName;
  final int? level;
  final String? className;
  final List<ParsedStat> stats;

  const ParsedSheetData({
    this.characterName,
    this.level,
    this.className,
    required this.stats,
  });

  bool get isEmpty => level == null && className == null && stats.isEmpty;
}

class StatParser {
  // --- Level patterns ---
  static final _levelRe = RegExp(
    r'(?:level|lv\.?|lvl\.?)\s*[:=]?\s*(\d+)',
    caseSensitive: false,
  );

  // --- Class/Job patterns ---
  static final _classRe = RegExp(
    r'(?:class|job|profession|occupation|role)\s*[:=]\s*(.+?)(?:\n|$|[,;])',
    caseSensitive: false,
  );

  // --- Name pattern (often "Name: X" at start) ---
  static final _nameRe = RegExp(
    r'(?:name|character)\s*[:=]\s*(.+?)(?:\n|$|[,;])',
    caseSensitive: false,
  );

  // --- Race/Species ---
  static final _raceRe = RegExp(
    r'(?:race|species)\s*[:=]\s*(.+?)(?:\n|$|[,;])',
    caseSensitive: false,
  );

  // --- Title ---
  static final _titleRe = RegExp(
    r'(?:title)\s*[:=]\s*(.+?)(?:\n|$|[,;])',
    caseSensitive: false,
  );

  // --- Resource pools: HP, MP, SP, Mana, Health, Stamina ---
  static final _resourceRe = RegExp(
    r'(HP|MP|SP|Health|Mana|Stamina|Energy|Ki|Qi|Chi)\s*[:=]?\s*(\d[\d,]*(?:\s*/\s*\d[\d,]*)?)',
    caseSensitive: false,
  );

  // --- Core stats: STR, DEX, CON, INT, WIS, CHA, AGI, VIT, LUK, END ---
  static final _coreStatRe = RegExp(
    r'\b(STR|DEX|CON|INT|WIS|CHA|AGI|VIT|LUK|END|Strength|Dexterity|Constitution|Intelligence|Wisdom|Charisma|Agility|Vitality|Luck|Endurance)\s*[:=]?\s*(\d[\d,]*(?:\s*\(\s*[+\-]\d+\s*\))?)',
    caseSensitive: false,
  );

  // --- Multi-class: [ClassName – Level] e.g. [Koschei – 4] [Necromancer – 34] ---
  static final _multiClassRe = RegExp(
    r'\[([A-Za-z][\w\s]+?)\s*[-–—]\s*(\d+)\s*\]',
    caseSensitive: false,
  );

  // --- Skills: [Skill Name (Lvl X)] or Skill Name - Level X or Skill Name (Lv. X) ---
  static final _skillBracketRe = RegExp(
    r'\[([^\]]+?)(?:\s*\(\s*(?:lv\.?|lvl\.?|level)\s*(\d+)\s*\))?\s*\]',
    caseSensitive: false,
  );

  static final _skillDashRe = RegExp(
    r'([A-Z][\w\s]+?)\s*[-–]\s*(?:lv\.?|lvl\.?|level)\s*[:=]?\s*(\d+)',
    caseSensitive: false,
  );

  static final _skillColonRe = RegExp(
    r'([A-Z][\w\s]+?)\s*\(\s*(?:lv\.?|lvl\.?|level)\s*[:=]?\s*(\d+)\s*\)',
    caseSensitive: false,
  );

  // --- Generic "Key: Value" for remaining lines ---
  static final _genericKvRe = RegExp(
    r'^([A-Za-z][\w\s]{1,30})\s*[:=]\s*(.+)$',
    multiLine: true,
  );

  ParsedSheetData parse(String text) {
    String? name;
    int? level;
    String? className;
    final stats = <ParsedStat>[];
    final usedRanges = <_Range>[];

    // Name
    final nameMatch = _nameRe.firstMatch(text);
    if (nameMatch != null) {
      name = nameMatch.group(1)!.trim();
      usedRanges.add(_Range(nameMatch.start, nameMatch.end));
    }

    // Level
    final levelMatch = _levelRe.firstMatch(text);
    if (levelMatch != null) {
      level = int.tryParse(levelMatch.group(1)!);
      usedRanges.add(_Range(levelMatch.start, levelMatch.end));
    }

    // Class
    final classMatch = _classRe.firstMatch(text);
    if (classMatch != null) {
      className = classMatch.group(1)!.trim();
      usedRanges.add(_Range(classMatch.start, classMatch.end));
    }

    // Race
    final raceMatch = _raceRe.firstMatch(text);
    if (raceMatch != null) {
      stats.add(ParsedStat(key: 'Race', value: raceMatch.group(1)!.trim(), category: SheetCategory.custom));
      usedRanges.add(_Range(raceMatch.start, raceMatch.end));
    }

    // Title
    final titleMatch = _titleRe.firstMatch(text);
    if (titleMatch != null) {
      stats.add(ParsedStat(key: 'Title', value: titleMatch.group(1)!.trim(), category: SheetCategory.custom));
      usedRanges.add(_Range(titleMatch.start, titleMatch.end));
    }

    // Multi-class entries: [Name – Level]
    final classNames = <String>{};
    String? bestClassName;
    int bestClassLevel = 0;
    for (final match in _multiClassRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      final cName = match.group(1)!.trim();
      final cLevel = int.tryParse(match.group(2)!) ?? 0;
      classNames.add(cName.toLowerCase());
      if (cLevel > bestClassLevel) {
        bestClassLevel = cLevel;
        bestClassName = cName;
      }
      stats.add(ParsedStat(key: cName, value: '$cLevel', category: SheetCategory.custom));
      usedRanges.add(_Range(match.start, match.end));
    }
    // Set className from multi-class if not already set
    if (className == null && bestClassName != null) {
      className = bestClassName;
    }
    if (className != null) classNames.add(className!.toLowerCase());

    // Resources
    for (final match in _resourceRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      final key = _normalizeResourceKey(match.group(1)!);
      stats.add(ParsedStat(key: key, value: match.group(2)!.trim(), category: SheetCategory.resource));
      usedRanges.add(_Range(match.start, match.end));
    }

    // Core stats
    for (final match in _coreStatRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      final key = _normalizeStatKey(match.group(1)!);
      stats.add(ParsedStat(key: key, value: match.group(2)!.trim(), category: SheetCategory.stat));
      usedRanges.add(_Range(match.start, match.end));
    }

    // Skills (bracket format)
    for (final match in _skillBracketRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      final skillName = match.group(1)!.trim();
      final skillLevel = match.group(2);
      stats.add(ParsedStat(
        key: skillName,
        value: skillLevel != null ? 'Lv. $skillLevel' : 'Active',
        category: SheetCategory.skill,
      ));
      usedRanges.add(_Range(match.start, match.end));
    }

    // Skills (dash format)
    for (final match in _skillDashRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      stats.add(ParsedStat(
        key: match.group(1)!.trim(),
        value: 'Lv. ${match.group(2)!}',
        category: SheetCategory.skill,
      ));
      usedRanges.add(_Range(match.start, match.end));
    }

    // Skills (parenthetical format)
    for (final match in _skillColonRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      stats.add(ParsedStat(
        key: match.group(1)!.trim(),
        value: 'Lv. ${match.group(2)!}',
        category: SheetCategory.skill,
      ));
      usedRanges.add(_Range(match.start, match.end));
    }

    // Generic key-value pairs for anything not already matched
    for (final match in _genericKvRe.allMatches(text)) {
      if (_overlaps(usedRanges, match.start, match.end)) continue;
      final key = match.group(1)!.trim();
      final value = match.group(2)!.trim();
      // Skip if key looks like it was already handled
      if (_isHandledKey(key)) continue;
      // Skip if key matches a known class name
      if (classNames.contains(key.toLowerCase())) continue;
      stats.add(ParsedStat(key: key, value: value, category: SheetCategory.custom));
      usedRanges.add(_Range(match.start, match.end));
    }

    // Deduplicate: remove any skill whose key matches a class name
    stats.removeWhere((s) {
      if (s.category == SheetCategory.skill) {
        final keyLower = s.key.toLowerCase();
        // Check if skill key starts with or equals a class name
        for (final cn in classNames) {
          if (keyLower == cn || keyLower.startsWith('$cn ') || keyLower.startsWith('$cn\u2013') || keyLower.startsWith('$cn-')) {
            return true;
          }
        }
      }
      return false;
    });

    return ParsedSheetData(
      characterName: name,
      level: level,
      className: className,
      stats: stats,
    );
  }

  bool _overlaps(List<_Range> ranges, int start, int end) {
    return ranges.any((r) => start < r.end && end > r.start);
  }

  String _normalizeResourceKey(String raw) {
    switch (raw.toUpperCase()) {
      case 'HP':
      case 'HEALTH':
        return 'HP';
      case 'MP':
      case 'MANA':
        return 'MP';
      case 'SP':
      case 'STAMINA':
        return 'SP';
      default:
        return raw;
    }
  }

  String _normalizeStatKey(String raw) {
    switch (raw.toUpperCase()) {
      case 'STR':
      case 'STRENGTH':
        return 'STR';
      case 'DEX':
      case 'DEXTERITY':
        return 'DEX';
      case 'CON':
      case 'CONSTITUTION':
        return 'CON';
      case 'INT':
      case 'INTELLIGENCE':
        return 'INT';
      case 'WIS':
      case 'WISDOM':
        return 'WIS';
      case 'CHA':
      case 'CHARISMA':
        return 'CHA';
      case 'AGI':
      case 'AGILITY':
        return 'AGI';
      case 'VIT':
      case 'VITALITY':
        return 'VIT';
      case 'LUK':
      case 'LUCK':
        return 'LUK';
      case 'END':
      case 'ENDURANCE':
        return 'END';
      default:
        return raw;
    }
  }

  bool _isHandledKey(String key) {
    final lower = key.toLowerCase();
    return const [
      'name', 'character', 'level', 'lv', 'lvl', 'class', 'job',
      'profession', 'race', 'species', 'title', 'occupation', 'role',
      'total level',
    ].contains(lower);
  }
}

class _Range {
  final int start;
  final int end;
  const _Range(this.start, this.end);
}
