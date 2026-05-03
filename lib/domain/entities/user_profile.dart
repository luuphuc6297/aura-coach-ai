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

  /// Serializes the profile for Firestore.
  ///
  /// `forUpdate: true` is used by the Edit Profile flow — it omits `createdAt`
  /// so a `set(..., merge: true)` call doesn't overwrite the original creation
  /// timestamp captured during onboarding.
  Map<String, dynamic> toFirestore({bool forUpdate = false}) => {
        'name': name,
        'avatarId': avatarId,
        'avatarUrl': avatarUrl,
        'proficiencyLevel': proficiencyLevel,
        'selectedGoals': selectedGoals,
        'dailyMinutes': dailyMinutes,
        'selectedTopics': selectedTopics,
        'tier': tier,
        if (!forUpdate) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UserProfile copyWith({
    String? name,
    String? avatarId,
    String? avatarUrl,
    String? proficiencyLevel,
    List<String>? selectedGoals,
    int? dailyMinutes,
    List<String>? selectedTopics,
    String? tier,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      tier: tier ?? this.tier,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
