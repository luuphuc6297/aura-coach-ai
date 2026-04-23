import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String avatarId;
  final String avatarUrl;
  final String proficiencyLevel;
  final List<String> selectedGoals;
  final int dailyMinutes;
  final List<String> selectedTopics;
  final String tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.avatarId,
    required this.avatarUrl,
    required this.proficiencyLevel,
    required this.selectedGoals,
    required this.dailyMinutes,
    required this.selectedTopics,
    this.tier = 'free',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      avatarId: data['avatarId'] ?? 'fox',
      avatarUrl: data['avatarUrl'] ?? '',
      proficiencyLevel: data['proficiencyLevel'] ?? 'intermediate',
      selectedGoals: List<String>.from(data['selectedGoals'] ?? []),
      dailyMinutes: data['dailyMinutes'] ?? 15,
      selectedTopics: List<String>.from(data['selectedTopics'] ?? []),
      tier: data['tier'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'avatarId': avatarId,
        'avatarUrl': avatarUrl,
        'proficiencyLevel': proficiencyLevel,
        'selectedGoals': selectedGoals,
        'dailyMinutes': dailyMinutes,
        'selectedTopics': selectedTopics,
        'tier': tier,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
