/// Catatan tambahan (follow-up note) yang dapat ditambah, diedit, atau dihapus kapan saja
/// pada setiap entri Jurnal Seduh.
class JournalFollowUpNote {
  final int id;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JournalFollowUpNote({
    required this.id,
    required this.text,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalFollowUpNote.fromMap(Map<dynamic, dynamic> raw) {
    final idVal = raw['id'];
    final parsedId = idVal is int
        ? idVal
        : int.tryParse(idVal?.toString() ?? '') ??
            DateTime.now().microsecondsSinceEpoch;
    final created =
        DateTime.tryParse(raw['createdAt']?.toString() ?? '') ?? DateTime.now();
    final updatedRaw = raw['updatedAt']?.toString();
    return JournalFollowUpNote(
      id: parsedId,
      text: raw['text']?.toString() ?? '',
      createdAt: created,
      updatedAt: updatedRaw != null ? DateTime.tryParse(updatedRaw) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  JournalFollowUpNote copyWith({String? text, DateTime? updatedAt}) {
    return JournalFollowUpNote(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model terstruktur untuk satu entri Jurnal Seduh (kompatibel penuh dengan catatan lama & baru).
class BrewJournalEntry {
  final int id;
  final int? recipeId;
  final String title;
  final String author;
  final String method;
  final String beanName;
  final String grindSize;
  final double? doseGrams;
  final double? waterGrams;
  final int? tempCelsius;
  final double rating;
  final String notes;
  final Map<String, double> sensoryMetrics;
  final double sensoryMaxScale;
  final List<JournalFollowUpNote> additionalNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> rawExtra;

  const BrewJournalEntry({
    required this.id,
    this.recipeId,
    required this.title,
    this.author = '',
    this.method = '',
    this.beanName = '',
    this.grindSize = '',
    this.doseGrams,
    this.waterGrams,
    this.tempCelsius,
    required this.rating,
    required this.notes,
    this.sensoryMetrics = const {},
    this.sensoryMaxScale = 5.0,
    this.additionalNotes = const [],
    required this.createdAt,
    this.updatedAt,
    this.rawExtra = const {},
  });

  bool get hasSensoryChart => sensoryMetrics.length >= 3;

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v?.toString() ?? '');
  }

  /// Otomatis mengekstrak skor sensorik dari teks evaluasi lama (misal:
  /// `Asam: 3.5, Manis: 3.8, Pahit: 2.0, Body: 3.2, Clarity: 4.0` atau SCA Cupping)
  /// sehingga entri lama pun langsung memiliki tampilan grafik radar & batang.
  static ({Map<String, double> metrics, double maxScale}) parseSensoryFromNotes(
    String notes,
  ) {
    if (notes.trim().isEmpty) return (metrics: const {}, maxScale: 5.0);

    final metrics = <String, double>{};
    final patterns = <String, RegExp>{
      'Asam': RegExp(r'(?:Asam|Acidity)\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Manis': RegExp(r'(?:Manis|Sweetness)\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Pahit': RegExp(r'(?:Pahit|Bitterness)\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Body': RegExp(r'(?:Mouthfeel\s*/\s*Body|Body|Mouthfeel)\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Clarity': RegExp(r'Clarity\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Aroma': RegExp(r'Aroma\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Aftertaste': RegExp(r'Aftertaste\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      'Balance': RegExp(r'(?:Overall\s+Balance|Balance)\s*:\s*(\d+(?:\.\d+)?)', caseSensitive: false),
    };

    double maxFound = 0;
    for (final entry in patterns.entries) {
      final m = entry.value.firstMatch(notes);
      if (m != null) {
        final val = double.tryParse(m.group(1) ?? '');
        if (val != null && val >= 0) {
          metrics[entry.key] = val;
          if (val > maxFound) maxFound = val;
        }
      }
    }

    final maxScale = maxFound > 5.0 ? 10.0 : 5.0;
    return (metrics: metrics, maxScale: maxScale);
  }

  factory BrewJournalEntry.fromMap(Map<String, dynamic> map) {
    final id = _toInt(map['id']) ?? DateTime.now().millisecondsSinceEpoch;
    final rawTitle = (map['title']?.toString().trim().isNotEmpty == true)
        ? map['title'].toString().trim()
        : ((map['recipeTitle']?.toString().trim().isNotEmpty == true)
            ? map['recipeTitle'].toString().trim()
            : 'Catatan Seduh');
    final rawGrind = (map['grindSize']?.toString().trim().isNotEmpty == true)
        ? map['grindSize'].toString().trim()
        : (map['grindNote']?.toString().trim() ?? '');
    final notes = map['notes']?.toString() ?? '';

    Map<String, double> sensory = {};
    double maxScale = _toDouble(map['sensoryMaxScale']) ?? 5.0;
    if (map['sensoryMetrics'] is Map) {
      (map['sensoryMetrics'] as Map).forEach((k, v) {
        final parsed = _toDouble(v);
        if (parsed != null) sensory[k.toString()] = parsed;
      });
    }
    if (sensory.isEmpty) {
      final parsed = parseSensoryFromNotes(notes);
      sensory = parsed.metrics;
      maxScale = parsed.maxScale;
    }

    final rawAddNotes = map['additionalNotes'];
    final addNotes = <JournalFollowUpNote>[];
    if (rawAddNotes is List) {
      for (final item in rawAddNotes) {
        if (item is Map) {
          addNotes.add(JournalFollowUpNote.fromMap(item));
        }
      }
    }

    final created =
        DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now();
    final updatedRaw = map['updatedAt']?.toString();

    return BrewJournalEntry(
      id: id,
      recipeId: _toInt(map['recipeId']),
      title: rawTitle,
      author: map['author']?.toString() ?? '',
      method: map['method']?.toString() ?? '',
      beanName: map['beanName']?.toString() ?? '',
      grindSize: rawGrind,
      doseGrams: _toDouble(map['doseGrams']),
      waterGrams: _toDouble(map['waterGrams']),
      tempCelsius: _toInt(map['tempCelsius']),
      rating: (_toDouble(map['rating']) ?? 4.0).clamp(1.0, 5.0),
      notes: notes,
      sensoryMetrics: sensory,
      sensoryMaxScale: maxScale,
      additionalNotes: addNotes,
      createdAt: created,
      updatedAt: updatedRaw != null ? DateTime.tryParse(updatedRaw) : null,
      rawExtra: Map<String, dynamic>.from(map),
    );
  }

  Map<String, dynamic> toMap() {
    final merged = Map<String, dynamic>.from(rawExtra);
    merged.addAll({
      'id': id,
      'recipeId': recipeId,
      'title': title,
      'recipeTitle': title,
      'author': author,
      'method': method,
      'beanName': beanName,
      'grindSize': grindSize,
      'grindNote': grindSize,
      'doseGrams': doseGrams,
      'waterGrams': waterGrams,
      'tempCelsius': tempCelsius,
      'rating': rating,
      'notes': notes,
      'sensoryMetrics': sensoryMetrics,
      'sensoryMaxScale': sensoryMaxScale,
      'additionalNotes': additionalNotes.map((n) => n.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    });
    return merged;
  }

  BrewJournalEntry copyWith({
    int? recipeId,
    String? title,
    String? author,
    String? method,
    String? beanName,
    String? grindSize,
    double? doseGrams,
    double? waterGrams,
    int? tempCelsius,
    double? rating,
    String? notes,
    Map<String, double>? sensoryMetrics,
    double? sensoryMaxScale,
    List<JournalFollowUpNote>? additionalNotes,
    DateTime? updatedAt,
  }) {
    return BrewJournalEntry(
      id: id,
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      author: author ?? this.author,
      method: method ?? this.method,
      beanName: beanName ?? this.beanName,
      grindSize: grindSize ?? this.grindSize,
      doseGrams: doseGrams ?? this.doseGrams,
      waterGrams: waterGrams ?? this.waterGrams,
      tempCelsius: tempCelsius ?? this.tempCelsius,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      sensoryMetrics: sensoryMetrics ?? this.sensoryMetrics,
      sensoryMaxScale: sensoryMaxScale ?? this.sensoryMaxScale,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawExtra: rawExtra,
    );
  }
}
