class LearningGoal {
  final String id;
  final String label;
  final String description;
  final String emoji;

  const LearningGoal({
    required this.id,
    required this.label,
    required this.description,
    required this.emoji,
  });
}

const List<LearningGoal> learningGoals = [
  LearningGoal(
      id: 'career',
      label: 'Career growth',
      description: 'Speak confidently at work',
      emoji: '\u{1F4BC}'),
  LearningGoal(
      id: 'travel',
      label: 'Travel abroad',
      description: 'Navigate new countries easily',
      emoji: '\u{2708}\u{FE0F}'),
  LearningGoal(
      id: 'exam',
      label: 'Exam preparation',
      description: 'IELTS, TOEFL, Cambridge',
      emoji: '\u{1F393}'),
  LearningGoal(
      id: 'daily',
      label: 'Daily communication',
      description: 'Chat with friends & online',
      emoji: '\u{1F30D}'),
  LearningGoal(
      id: 'self',
      label: 'Self improvement',
      description: 'Personal growth & learning',
      emoji: '\u{1F9E0}'),
];

class DailyTimeOption {
  final int minutes;
  final String label;
  final String description;
  final String iconId;

  const DailyTimeOption({
    required this.minutes,
    required this.label,
    required this.description,
    required this.iconId,
  });
}

const List<DailyTimeOption> dailyTimeOptions = [
  DailyTimeOption(
      minutes: 5,
      label: '5 minutes',
      description: 'Casual \u{2022} Easy start',
      iconId: 'time_seedling'),
  DailyTimeOption(
      minutes: 15,
      label: '15 minutes',
      description: 'Regular \u{2022} Recommended',
      iconId: 'time_fire'),
  DailyTimeOption(
      minutes: 30,
      label: '30 minutes',
      description: 'Intensive \u{2022} Fast progress',
      iconId: 'time_bolt'),
  DailyTimeOption(
      minutes: 60,
      label: '60 minutes',
      description: 'Serious \u{2022} Maximum results',
      iconId: 'time_rocket'),
];

enum ProficiencyLevel {
  beginner(
      'beginner', 'Beginner', 'A1 / A2', 'Basic phrases & simple sentences'),
  intermediate('intermediate', 'Intermediate', 'B1 / B2',
      'Everyday conversations & complex topics'),
  advanced('advanced', 'Advanced', 'C1 / C2',
      'Complex discussions & near-native fluency');

  final String id;
  final String label;
  final String cefr;
  final String description;

  const ProficiencyLevel(this.id, this.label, this.cefr, this.description);
}
