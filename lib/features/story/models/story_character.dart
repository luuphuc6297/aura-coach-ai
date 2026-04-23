class StoryCharacter {
  final String name;
  final String role;
  final String personality;
  final String initial;
  final String gradient;

  const StoryCharacter({
    required this.name,
    required this.role,
    required this.personality,
    required this.initial,
    required this.gradient,
  });

  factory StoryCharacter.fromJson(Map<String, dynamic> json) => StoryCharacter(
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        personality: json['personality'] as String? ?? '',
        initial: json['initial'] as String? ??
            ((json['name'] as String? ?? '?').isNotEmpty
                ? (json['name'] as String).substring(0, 1).toUpperCase()
                : '?'),
        gradient: json['gradient'] as String? ?? 'teal-purple',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'personality': personality,
        'initial': initial,
        'gradient': gradient,
      };
}
