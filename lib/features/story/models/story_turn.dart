import '../../scenario/models/assessment.dart';

enum StoryTurnRole { system, user, ai }

extension StoryTurnRoleX on StoryTurnRole {
  String get value => name;
  static StoryTurnRole fromString(String? raw) {
    switch (raw) {
      case 'user':
        return StoryTurnRole.user;
      case 'ai':
        return StoryTurnRole.ai;
      case 'system':
        return StoryTurnRole.system;
      default:
        return StoryTurnRole.user;
    }
  }
}

class StoryTurn {
  final String id;
  final StoryTurnRole role;
  final String text;
  final DateTime timestamp;
  final AssessmentResult? assessment;

  const StoryTurn({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.assessment,
  });

  factory StoryTurn.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String?;
    if (rawRole == 'assessment') {
      throw StateError(
        'Story turns must never have role="assessment". '
        'Assessments live INLINE on role="user" turns.',
      );
    }
    final role = StoryTurnRoleX.fromString(rawRole);
    AssessmentResult? assessment;
    final raw = json['assessment'];
    if (raw is Map) {
      assessment = AssessmentResult.fromJson(Map<String, dynamic>.from(raw));
    }
    return StoryTurn(
      id: json['id'] as String? ?? '',
      role: role,
      text: json['text'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      assessment: assessment,
    );
  }

  /// Resume-safe variant of [fromJson]. Returns `null` for turn shapes that
  /// must never appear in a fresh Story session — specifically the legacy
  /// `role="assessment"` shape from the Scenario Coach schema. Used by
  /// [StorySession.fromJson] so a single bad turn cannot abort an otherwise
  /// healthy resume.
  static StoryTurn? tryFromJson(Map<String, dynamic> json) {
    try {
      return StoryTurn.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.value,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        if (assessment != null) 'assessment': assessment!.toJson(),
      };

  StoryTurn copyWith({AssessmentResult? assessment}) => StoryTurn(
        id: id,
        role: role,
        text: text,
        timestamp: timestamp,
        assessment: assessment ?? this.assessment,
      );
}
