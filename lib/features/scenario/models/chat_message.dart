import 'assessment.dart';

enum MessageType { system, ai, user, assessment }

class ChatMessage {
  final String id;
  final MessageType type;
  final String text;
  final DateTime timestamp;
  final AssessmentResult? assessment;
  final String? savedPhrase;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
    this.assessment,
    this.savedPhrase,
  });
}
