import 'dart:math';

/// Extracts characters, world areas, and connections from book text
/// using offline heuristic NLP techniques.

class ExtractedEntity {
  final String name;
  final double confidence;
  final int mentionCount;
  final List<String> evidence;
  bool selected;

  ExtractedEntity({
    required this.name,
    required this.confidence,
    required this.mentionCount,
    required this.evidence,
    this.selected = true,
  });
}

class ExtractedConnection {
  final String entityA;
  final String entityB;
  final int coOccurrenceCount;
  final List<String> chapters;
  bool selected;

  ExtractedConnection({
    required this.entityA,
    required this.entityB,
    required this.coOccurrenceCount,
    required this.chapters,
    this.selected = true,
  });
}

class ExtractionProgress {
  final String stage;
  final double progress;
  final String detail;
  const ExtractionProgress(this.stage, this.progress, this.detail);
}

class HeuristicExtractor {
  // Common English words that should never be character names
  static final _stopWords = {
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'is', 'was', 'are', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'shall', 'can', 'this', 'that',
    'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me',
    'him', 'her', 'us', 'them', 'my', 'your', 'his', 'its', 'our', 'their',
    'what', 'which', 'who', 'whom', 'when', 'where', 'why', 'how', 'all',
    'each', 'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such',
    'no', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 'just',
    'because', 'as', 'until', 'while', 'about', 'between', 'through',
    'during', 'before', 'after', 'above', 'below', 'up', 'down', 'out',
    'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here',
    'there', 'any', 'if', 'into', 'also', 'new', 'old', 'first', 'last',
    'long', 'great', 'little', 'right', 'left', 'still', 'even', 'back',
    'much', 'well', 'away', 'around', 'never', 'always', 'sometimes',
    'now', 'part', 'take', 'come', 'make', 'like', 'time', 'just', 'know',
    'get', 'go', 'see', 'think', 'look', 'want', 'give', 'use', 'find',
    'tell', 'ask', 'work', 'seem', 'feel', 'try', 'leave', 'call',
    // Common chapter/book words
    'chapter', 'prologue', 'epilogue', 'part', 'book', 'volume',
    'contents', 'table', 'copyright', 'author', 'note', 'preface',
    'introduction', 'acknowledgments', 'dedication', 'appendix',
    // Common false positives
    'mr', 'mrs', 'ms', 'sir', 'lord', 'lady', 'king', 'queen',
    'prince', 'princess', 'captain', 'general', 'master', 'miss',
    'doctor', 'professor', 'father', 'mother', 'brother', 'sister',
    'uncle', 'aunt', 'god', 'gods', 'goddess',
    // Days/months
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday',
    'sunday', 'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  };

  // Honorifics that precede character names
  static final _honorifics = {
    'mr', 'mrs', 'ms', 'miss', 'dr', 'sir', 'lord', 'lady', 'king',
    'queen', 'prince', 'princess', 'captain', 'general', 'commander',
    'master', 'professor', 'father', 'mother', 'brother', 'sister',
    'elder', 'chief', 'duke', 'duchess', 'baron', 'count', 'countess',
  };

  // Dialogue verbs that indicate a character
  static final _dialogueVerbs = RegExp(
    r'\b(said|asked|replied|answered|whispered|shouted|yelled|muttered|'
    r'murmured|exclaimed|cried|called|screamed|growled|snarled|hissed|'
    r'snapped|barked|laughed|chuckled|sighed|groaned|moaned|breathed|'
    r'stammered|stuttered|declared|announced|stated|insisted|demanded|'
    r'pleaded|begged|warned|threatened|promised|agreed|objected|protested|'
    r'interrupted|continued|added|began|spoke|told|explained)\b',
    caseSensitive: false,
  );

  // Spatial prepositions that indicate a location
  static final _spatialPreps = RegExp(
    r'\b(in|at|to|from|near|toward|towards|through|across|beyond|'
    r'inside|outside|within|above|below|beneath|beside|between|around|'
    r'entered|left|arrived|traveled|journeyed|visited|reached|approached|'
    r'departed|returned|headed|walked|rode|sailed|flew)\b',
    caseSensitive: false,
  );

  // Location indicator words
  static final _locationWords = {
    'city', 'town', 'village', 'kingdom', 'empire', 'realm', 'land',
    'forest', 'mountain', 'river', 'sea', 'ocean', 'lake', 'island',
    'castle', 'palace', 'tower', 'dungeon', 'cave', 'temple', 'church',
    'inn', 'tavern', 'market', 'square', 'gate', 'bridge', 'road',
    'path', 'street', 'district', 'quarter', 'region', 'province',
    'continent', 'world', 'valley', 'plain', 'desert', 'swamp', 'marsh',
    'harbor', 'port', 'fortress', 'citadel', 'keep', 'hall', 'academy',
    'guild', 'arena', 'coliseum', 'library', 'labyrinth', 'ruins',
    'sanctuary', 'shrine', 'monastery', 'camp', 'outpost', 'border',
    'wasteland', 'woods', 'grove', 'clearing', 'peak', 'summit',
    'cliff', 'coast', 'shore', 'bay', 'cove', 'pass', 'gorge', 'canyon',
  };

  /// Extract all chapters' plain text from HTML strings.
  List<String> chaptersToPlainText(List<String> htmlChapters) {
    return htmlChapters.map(_stripHtml).toList();
  }

  /// Extract potential character names from text.
  List<ExtractedEntity> extractCharacters(List<String> chapterTexts) {
    final nameScores = <String, _EntityScore>{};

    for (var ci = 0; ci < chapterTexts.length; ci++) {
      final text = chapterTexts[ci];
      final paragraphs = text.split(RegExp(r'\n\n+'));

      for (final para in paragraphs) {
        // 1. Dialogue attribution: "..." said Name / Name said "..."
        _extractDialogueNames(para, nameScores, ci);

        // 2. Proper nouns (capitalized words not at sentence start)
        _extractProperNouns(para, nameScores, ci);

        // 3. Honorific + Name patterns
        _extractHonorificNames(para, nameScores, ci);
      }
    }

    // Merge similar names (e.g., "John" and "John Smith")
    _mergeNames(nameScores);

    // Convert to entities with confidence scoring
    final entities = <ExtractedEntity>[];
    for (final entry in nameScores.entries) {
      final score = entry.value;
      if (score.totalMentions < 2) continue;

      final confidence = _calculateCharacterConfidence(score);
      if (confidence < 0.2) continue;

      entities.add(ExtractedEntity(
        name: entry.key,
        confidence: confidence,
        mentionCount: score.totalMentions,
        evidence: score.evidence.toSet().take(3).toList(),
        selected: confidence >= 0.5,
      ));
    }

    // Sort by confidence * mentions (most likely characters first)
    entities.sort((a, b) => (b.confidence * b.mentionCount).compareTo(a.confidence * a.mentionCount));

    return entities;
  }

  /// Extract potential world areas / locations from text.
  List<ExtractedEntity> extractWorldAreas(
    List<String> chapterTexts, {
    List<String> knownCharacterNames = const [],
  }) {
    final locationScores = <String, _EntityScore>{};
    final charNamesLower = knownCharacterNames.map((n) => n.toLowerCase()).toSet();

    for (var ci = 0; ci < chapterTexts.length; ci++) {
      final text = chapterTexts[ci];

      // 1. Spatial preposition + Capitalized Name
      _extractSpatialLocations(text, locationScores, ci, charNamesLower);

      // 2. "the X of Y" patterns where X is a location word
      _extractLocationPhrases(text, locationScores, ci, charNamesLower);

      // 3. Capitalized words near location indicator words
      _extractNearLocationWords(text, locationScores, ci, charNamesLower);
    }

    final entities = <ExtractedEntity>[];
    for (final entry in locationScores.entries) {
      final score = entry.value;
      if (score.totalMentions < 2) continue;

      final confidence = _calculateLocationConfidence(score);
      if (confidence < 0.15) continue;

      // Skip if it's already a known character name
      if (charNamesLower.contains(entry.key.toLowerCase())) continue;

      entities.add(ExtractedEntity(
        name: entry.key,
        confidence: confidence,
        mentionCount: score.totalMentions,
        evidence: score.evidence.toSet().take(3).toList(),
        selected: confidence >= 0.4,
      ));
    }

    entities.sort((a, b) => (b.confidence * b.mentionCount).compareTo(a.confidence * a.mentionCount));
    return entities;
  }

  /// Detect connections between entities based on paragraph co-occurrence.
  List<ExtractedConnection> extractConnections(
    List<String> chapterTexts,
    List<String> characterNames,
    List<String> worldAreaNames,
  ) {
    final allNames = [...characterNames, ...worldAreaNames];
    final coOccurrences = <String, _CoOccurrenceScore>{};

    for (var ci = 0; ci < chapterTexts.length; ci++) {
      final text = chapterTexts[ci];
      final paragraphs = text.split(RegExp(r'\n\n+'));
      final chLabel = 'Ch. ${ci + 1}';

      for (final para in paragraphs) {
        final paraLower = para.toLowerCase();
        final found = <String>[];

        for (final name in allNames) {
          if (_containsWord(paraLower, name.toLowerCase())) {
            found.add(name);
          }
        }

        // Create pairs
        for (var i = 0; i < found.length; i++) {
          for (var j = i + 1; j < found.length; j++) {
            final a = found[i].compareTo(found[j]) < 0 ? found[i] : found[j];
            final b = found[i].compareTo(found[j]) < 0 ? found[j] : found[i];
            final key = '$a|$b';
            coOccurrences.putIfAbsent(key, () => _CoOccurrenceScore(a, b));
            coOccurrences[key]!.count++;
            coOccurrences[key]!.chapters.add(chLabel);
          }
        }
      }
    }

    final connections = coOccurrences.values
        .where((c) => c.count >= 2)
        .map((c) => ExtractedConnection(
              entityA: c.entityA,
              entityB: c.entityB,
              coOccurrenceCount: c.count,
              chapters: c.chapters.toSet().toList()..sort(),
              selected: c.count >= 3,
            ))
        .toList();

    connections.sort((a, b) => b.coOccurrenceCount.compareTo(a.coOccurrenceCount));
    return connections;
  }

  // ─── Private helpers ─────────────────────────────────────────────

  void _extractDialogueNames(String para, Map<String, _EntityScore> scores, int chapter) {
    // Pattern: dialogue verb + Name
    final afterVerb = RegExp(
      r'(?:said|asked|replied|whispered|shouted|muttered|exclaimed|cried|called|'
      r'growled|snarled|hissed|snapped|declared|announced|demanded|warned|spoke)\s+'
      r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
    );

    for (final match in afterVerb.allMatches(para)) {
      final name = match.group(1)!.trim();
      if (_isValidName(name)) {
        scores.putIfAbsent(name, () => _EntityScore());
        scores[name]!.dialogueCount++;
        scores[name]!.totalMentions++;
        scores[name]!.chapters.add(chapter);
        scores[name]!.evidence.add('Dialogue: "...${match.group(0)}"');
      }
    }

    // Pattern: Name + dialogue verb
    final beforeVerb = RegExp(
      r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)\s+'
      r'(?:said|asked|replied|whispered|shouted|muttered|exclaimed|cried|called|'
      r'growled|snarled|hissed|snapped|declared|announced|demanded|warned|spoke)',
    );

    for (final match in beforeVerb.allMatches(para)) {
      final name = match.group(1)!.trim();
      if (_isValidName(name)) {
        scores.putIfAbsent(name, () => _EntityScore());
        scores[name]!.dialogueCount++;
        scores[name]!.totalMentions++;
        scores[name]!.chapters.add(chapter);
        scores[name]!.evidence.add('Dialogue: "${match.group(0)}..."');
      }
    }
  }

  void _extractProperNouns(String para, Map<String, _EntityScore> scores, int chapter) {
    // Find capitalized words that aren't at the start of sentences
    final sentences = para.split(RegExp(r'[.!?]+\s+'));

    for (final sentence in sentences) {
      final trimmed = sentence.trim();
      if (trimmed.isEmpty) continue;

      // Match capitalized words after the first word of the sentence
      final words = trimmed.split(RegExp(r'\s+'));
      for (var i = 1; i < words.length; i++) {
        final word = words[i].replaceAll(RegExp(r"[^a-zA-Z'-]"), '');
        if (word.length < 2) continue;
        if (word[0] != word[0].toUpperCase() || word[0] == word[0].toLowerCase()) continue;

        // Check for multi-word names
        String name = word;
        if (i + 1 < words.length) {
          final next = words[i + 1].replaceAll(RegExp(r"[^a-zA-Z'-]"), '');
          if (next.isNotEmpty && next[0] == next[0].toUpperCase() && next[0] != next[0].toLowerCase()) {
            name = '$word $next';
          }
        }

        if (_isValidName(name)) {
          scores.putIfAbsent(name, () => _EntityScore());
          scores[name]!.properNounCount++;
          scores[name]!.totalMentions++;
          scores[name]!.chapters.add(chapter);
        }
      }
    }
  }

  void _extractHonorificNames(String para, Map<String, _EntityScore> scores, int chapter) {
    for (final hon in _honorifics) {
      final pattern = RegExp(
        '\\b${RegExp.escape(hon)}\\.?\\s+([A-Z][a-z]+(?:\\s+[A-Z][a-z]+)?)',
        caseSensitive: false,
      );

      for (final match in pattern.allMatches(para)) {
        final name = match.group(1)!.trim();
        final fullName = '${hon[0].toUpperCase()}${hon.substring(1)} $name';
        if (_isValidName(name)) {
          // Store as both the short name and full name
          scores.putIfAbsent(name, () => _EntityScore());
          scores[name]!.honorificCount++;
          scores[name]!.totalMentions++;
          scores[name]!.chapters.add(chapter);
          scores[name]!.evidence.add('Title: "$fullName"');
        }
      }
    }
  }

  void _extractSpatialLocations(
    String text,
    Map<String, _EntityScore> scores,
    int chapter,
    Set<String> charNames,
  ) {
    // "in/at/to/from + the? + Capitalized Name"
    final pattern = RegExp(
      r'\b(?:in|at|to|from|near|toward|towards|through|across|beyond|'
      r'entered|left|arrived|reached|approached|departed|returned)\s+'
      r'(?:the\s+)?([A-Z][a-z]+(?:\s+(?:of\s+)?[A-Z][a-z]+)*)',
    );

    for (final match in pattern.allMatches(text)) {
      final name = match.group(1)!.trim();
      if (name.length < 3) continue;
      if (charNames.contains(name.toLowerCase())) continue;
      if (_isStopWord(name)) continue;

      scores.putIfAbsent(name, () => _EntityScore());
      scores[name]!.spatialCount++;
      scores[name]!.totalMentions++;
      scores[name]!.chapters.add(chapter);
      scores[name]!.evidence.add('Spatial: "${match.group(0)}"');
    }
  }

  void _extractLocationPhrases(
    String text,
    Map<String, _EntityScore> scores,
    int chapter,
    Set<String> charNames,
  ) {
    // "the Forest of X", "the Kingdom of Y"
    for (final locWord in _locationWords) {
      final pattern = RegExp(
        '\\bthe\\s+$locWord\\s+of\\s+([A-Z][a-z]+(?:\\s+[A-Z][a-z]+)?)',
        caseSensitive: false,
      );

      for (final match in pattern.allMatches(text)) {
        final fullName = '${locWord[0].toUpperCase()}${locWord.substring(1)} of ${match.group(1)!.trim()}';
        if (charNames.contains(fullName.toLowerCase())) continue;

        scores.putIfAbsent(fullName, () => _EntityScore());
        scores[fullName]!.locationPhraseCount++;
        scores[fullName]!.totalMentions++;
        scores[fullName]!.chapters.add(chapter);
        scores[fullName]!.evidence.add('Pattern: "the $fullName"');
      }
    }
  }

  void _extractNearLocationWords(
    String text,
    Map<String, _EntityScore> scores,
    int chapter,
    Set<String> charNames,
  ) {
    // Capitalized name immediately before a location word
    for (final locWord in _locationWords) {
      final pattern = RegExp(
        '([A-Z][a-z]+)\\s+${RegExp.escape(locWord)}\\b',
      );

      for (final match in pattern.allMatches(text)) {
        final baseName = match.group(1)!.trim();
        final name = '$baseName ${locWord[0].toUpperCase()}${locWord.substring(1)}';
        if (charNames.contains(baseName.toLowerCase())) continue;
        if (_isStopWord(baseName)) continue;

        scores.putIfAbsent(name, () => _EntityScore());
        scores[name]!.locationPhraseCount++;
        scores[name]!.totalMentions++;
        scores[name]!.chapters.add(chapter);
        scores[name]!.evidence.add('Location: "${match.group(0)}"');
      }
    }
  }

  void _mergeNames(Map<String, _EntityScore> scores) {
    final keys = scores.keys.toList();
    final merged = <String, String>{};

    for (var i = 0; i < keys.length; i++) {
      for (var j = i + 1; j < keys.length; j++) {
        final a = keys[i];
        final b = keys[j];

        // If one name contains the other (e.g., "John" and "John Smith")
        if (a.contains(b) && a != b) {
          merged[b] = a; // merge short into long
        } else if (b.contains(a) && a != b) {
          merged[a] = b;
        }
      }
    }

    for (final entry in merged.entries) {
      if (scores.containsKey(entry.key) && scores.containsKey(entry.value)) {
        scores[entry.value]!.merge(scores[entry.key]!);
        scores.remove(entry.key);
      }
    }
  }

  double _calculateCharacterConfidence(_EntityScore score) {
    double conf = 0.0;

    // Dialogue attribution is strongest signal
    conf += min(score.dialogueCount * 0.15, 0.5);

    // Honorific usage
    conf += min(score.honorificCount * 0.12, 0.3);

    // Proper noun frequency (weaker signal alone)
    conf += min(score.properNounCount * 0.02, 0.3);

    // Appearing in multiple chapters is a strong signal
    final chapterSpread = score.chapters.toSet().length;
    conf += min(chapterSpread * 0.05, 0.3);

    // High mention count
    conf += min(score.totalMentions * 0.005, 0.2);

    return conf.clamp(0.0, 1.0);
  }

  double _calculateLocationConfidence(_EntityScore score) {
    double conf = 0.0;

    // Spatial preposition context
    conf += min(score.spatialCount * 0.12, 0.5);

    // Location phrase patterns
    conf += min(score.locationPhraseCount * 0.15, 0.4);

    // Multi-chapter appearance
    final chapterSpread = score.chapters.toSet().length;
    conf += min(chapterSpread * 0.05, 0.3);

    // Mentions
    conf += min(score.totalMentions * 0.005, 0.15);

    return conf.clamp(0.0, 1.0);
  }

  bool _isValidName(String name) {
    if (name.length < 2 || name.length > 40) return false;
    final words = name.split(' ');
    for (final w in words) {
      final clean = w.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
      if (_stopWords.contains(clean)) return false;
      if (clean.length < 2) return false;
    }
    return true;
  }

  bool _isStopWord(String word) {
    return _stopWords.contains(word.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]'), ''));
  }

  bool _containsWord(String text, String word) {
    final pattern = RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'&[a-z]+;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r' \n'), '\n')
        .trim();
  }
}

class _EntityScore {
  int dialogueCount = 0;
  int properNounCount = 0;
  int honorificCount = 0;
  int spatialCount = 0;
  int locationPhraseCount = 0;
  int totalMentions = 0;
  final chapters = <int>{};
  final evidence = <String>[];

  void merge(_EntityScore other) {
    dialogueCount += other.dialogueCount;
    properNounCount += other.properNounCount;
    honorificCount += other.honorificCount;
    spatialCount += other.spatialCount;
    locationPhraseCount += other.locationPhraseCount;
    totalMentions += other.totalMentions;
    chapters.addAll(other.chapters);
    evidence.addAll(other.evidence);
  }
}

class _CoOccurrenceScore {
  final String entityA;
  final String entityB;
  int count = 0;
  final chapters = <String>{};

  _CoOccurrenceScore(this.entityA, this.entityB);
}
