class SavedItem {
  final String id;
  final String original;
  final String correction;
  final String type;
  final String context;
  final int timestamp;
  final int masteryScore;
  final String? explanation;
  final List<Map<String, String>>? examples;
  final String? partOfSpeech;
  final String? imageUrl;
  final double? nextReviewDate;
  final int interval;
  final double easeFactor;
  final int reviewCount;
  final String? category;
  final String? pronunciation;
  final String? sourceTag;
  final String? illustrationEmoji;
  final List<String>? synonyms;
  final String? contextUsage;

  const SavedItem({
    required this.id,
    required this.original,
    required this.correction,
    required this.type,
    required this.context,
    required this.timestamp,
    this.masteryScore = 0,
    this.explanation,
    this.examples,
    this.partOfSpeech,
    this.imageUrl,
    this.nextReviewDate,
    this.interval = 0,
    this.easeFactor = 2.5,
    this.reviewCount = 0,
    this.category,
    this.pronunciation,
    this.sourceTag,
    this.illustrationEmoji,
    this.synonyms,
    this.contextUsage,
  });

  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= nextReviewDate!;
  }

  int get daysUntilReview {
    if (nextReviewDate == null) return 0;
    final diff = nextReviewDate! - DateTime.now().millisecondsSinceEpoch;
    return (diff / (1000 * 60 * 60 * 24)).ceil().clamp(0, 999);
  }

  SavedItem copyWith({
    String? id,
    String? original,
    String? correction,
    String? type,
    String? context,
    int? timestamp,
    int? masteryScore,
    String? explanation,
    List<Map<String, String>>? examples,
    String? partOfSpeech,
    String? imageUrl,
    double? nextReviewDate,
    int? interval,
    double? easeFactor,
    int? reviewCount,
    String? category,
    String? pronunciation,
    String? sourceTag,
    String? illustrationEmoji,
    List<String>? synonyms,
    String? contextUsage,
  }) {
    return SavedItem(
      id: id ?? this.id,
      original: original ?? this.original,
      correction: correction ?? this.correction,
      type: type ?? this.type,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      masteryScore: masteryScore ?? this.masteryScore,
      explanation: explanation ?? this.explanation,
      examples: examples ?? this.examples,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      imageUrl: imageUrl ?? this.imageUrl,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      pronunciation: pronunciation ?? this.pronunciation,
      sourceTag: sourceTag ?? this.sourceTag,
      illustrationEmoji: illustrationEmoji ?? this.illustrationEmoji,
      synonyms: synonyms ?? this.synonyms,
      contextUsage: contextUsage ?? this.contextUsage,
    );
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String? ?? '',
      original: json['original'] as String? ?? '',
      correction: json['correction'] as String? ?? '',
      type: json['type'] as String? ?? 'vocabulary',
      context: json['context'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      masteryScore: (json['masteryScore'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => (e as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v.toString())))
          .toList(),
      partOfSpeech: json['partOfSpeech'] as String?,
      imageUrl: json['imageUrl'] as String?,
      nextReviewDate: (json['nextReviewDate'] as num?)?.toDouble(),
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      category: json['category'] as String?,
      pronunciation: json['pronunciation'] as String?,
      sourceTag: json['sourceTag'] as String?,
      illustrationEmoji: json['illustrationEmoji'] as String?,
      synonyms: (json['synonyms'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      contextUsage: json['contextUsage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original': original,
      'correction': correction,
      'type': type,
      'context': context,
      'timestamp': timestamp,
      'masteryScore': masteryScore,
      'explanation': explanation,
      'examples':
          examples?.map((e) => e.map((k, v) => MapEntry(k, v))).toList(),
      'partOfSpeech': partOfSpeech,
      'imageUrl': imageUrl,
      'nextReviewDate': nextReviewDate,
      'interval': interval,
      'easeFactor': easeFactor,
      'reviewCount': reviewCount,
      'category': category,
      'pronunciation': pronunciation,
      'sourceTag': sourceTag,
      'illustrationEmoji': illustrationEmoji,
      'synonyms': synonyms,
      'contextUsage': contextUsage,
    };
  }

  factory SavedItem.fromImprovement({
    required String id,
    required String original,
    required String correction,
    required String type,
    required String context,
    String? sourceTag,
  }) {
    // Schedule new items for tomorrow so they don't pollute today's review
    // queue. SM-2 treats this as the first scheduled interval.
    final tomorrow = DateTime.now()
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch
        .toDouble();
    return SavedItem(
      id: id,
      original: original,
      correction: correction,
      type: type,
      context: context,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      nextReviewDate: tomorrow,
      interval: 1,
      sourceTag: sourceTag,
    );
  }
}
