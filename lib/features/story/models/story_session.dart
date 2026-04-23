import 'story_character.dart';
import 'story_turn.dart';

/// Two real states now that Back no longer auto-abandons a session:
/// `inProgress` while a session is open, `completed` once the learner has
/// reviewed and closed it. Legacy Firestore docs with `status: 'abandoned'`
/// are silently folded back into `inProgress` on read so older devices do
/// not lose work.
enum StorySessionStatus { inProgress, completed }

extension StorySessionStatusX on StorySessionStatus {
  String get wireValue {
    switch (this) {
      case StorySessionStatus.inProgress:
        return 'in-progress';
      case StorySessionStatus.completed:
        return 'completed';
    }
  }

  static StorySessionStatus fromWire(String? raw) {
    switch (raw) {
      case 'completed':
        return StorySessionStatus.completed;
      case 'abandoned':
      case 'in-progress':
      default:
        return StorySessionStatus.inProgress;
    }
  }
}

class StorySession {
  final String conversationId;
  final String? storyId;
  final String title;
  final String situation;
  final StoryCharacter character;
  final String topic;
  final String level;
  final String? customContext;
  final String? characterPreference;
  final StorySessionStatus status;
  final List<StoryTurn> turns;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime updatedAt;
  final bool quotaCharged;

  /// Cached level1 / level2 / level3 hints from the initial scenario
  /// generation. The Story chat screen serves these the first time the
  /// learner taps "Hint" before the AI has been re-prompted for fresh hints
  /// on subsequent turns.
  final List<String>? openingHints;

  const StorySession({
    required this.conversationId,
    required this.storyId,
    required this.title,
    required this.situation,
    required this.character,
    required this.topic,
    required this.level,
    required this.customContext,
    required this.characterPreference,
    required this.status,
    required this.turns,
    required this.startedAt,
    required this.endedAt,
    required this.updatedAt,
    required this.quotaCharged,
    this.openingHints,
  });

  int get userTurnCount =>
      turns.where((t) => t.role == StoryTurnRole.user).length;

  double get averageScore {
    final scored = turns
        .where((t) => t.role == StoryTurnRole.user && t.assessment != null)
        .map((t) => t.assessment!.score)
        .toList();
    if (scored.isEmpty) return 0;
    return scored.reduce((a, b) => a + b) / scored.length;
  }

  factory StorySession.fromJson(Map<String, dynamic> json) {
    final rawTurns = json['turns'] as List<dynamic>? ?? const [];
    final rawHints = json['openingHints'];
    List<String>? openingHints;
    if (rawHints is List) {
      openingHints =
          rawHints.whereType<String>().where((s) => s.isNotEmpty).toList();
      if (openingHints.isEmpty) openingHints = null;
    }
    return StorySession(
      conversationId: json['conversationId'] as String? ?? '',
      storyId: json['storyId'] as String?,
      title: json['title'] as String? ?? '',
      situation: json['situation'] as String? ?? '',
      character: StoryCharacter.fromJson(
        (json['character'] as Map<String, dynamic>?) ?? const {},
      ),
      topic: json['topic'] as String? ?? 'social',
      level: json['level'] as String? ?? 'B1',
      customContext: json['customContext'] as String?,
      characterPreference: json['characterPreference'] as String?,
      status: StorySessionStatusX.fromWire(json['status'] as String?),
      turns: rawTurns
          .whereType<Map<String, dynamic>>()
          .map(StoryTurn.tryFromJson)
          .whereType<StoryTurn>()
          .toList(),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      quotaCharged: json['quotaCharged'] as bool? ?? false,
      openingHints: openingHints,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': 'story',
        'conversationId': conversationId,
        'storyId': storyId,
        'title': title,
        'situation': situation,
        'character': character.toJson(),
        'topic': topic,
        'level': level,
        'customContext': customContext,
        'characterPreference': characterPreference,
        'status': status.wireValue,
        'turns': turns.map((t) => t.toJson()).toList(),
        'totalScore': averageScore,
        'turnCount': userTurnCount,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'quotaCharged': quotaCharged,
        if (openingHints != null) 'openingHints': openingHints,
      };

  StorySession copyWith({
    StorySessionStatus? status,
    List<StoryTurn>? turns,
    DateTime? endedAt,
    DateTime? updatedAt,
    bool? quotaCharged,
    List<String>? openingHints,
  }) =>
      StorySession(
        conversationId: conversationId,
        storyId: storyId,
        title: title,
        situation: situation,
        character: character,
        topic: topic,
        level: level,
        customContext: customContext,
        characterPreference: characterPreference,
        status: status ?? this.status,
        turns: turns ?? this.turns,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        quotaCharged: quotaCharged ?? this.quotaCharged,
        openingHints: openingHints ?? this.openingHints,
      );
}
