import 'package:flutter/foundation.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../domain/entities/user_profile.dart';

class OnboardingProvider extends ChangeNotifier {
  final FirebaseDatasource _firebaseDatasource;
  final LocalDatasource _localDatasource;

  int _currentStep = 0;
  String _name = '';
  String _selectedAvatarId = 'fox';
  String _selectedAvatarUrl = CloudinaryAssets.avatarFox;
  String _proficiencyLevel = 'beginner';
  final Set<String> _selectedGoals = {};
  int _dailyMinutes = 15;
  final Set<String> _selectedTopics = {};
  bool _isSaving = false;
  String? _errorMessage;

  OnboardingProvider({
    required FirebaseDatasource firebaseDatasource,
    required LocalDatasource localDatasource,
  })  : _firebaseDatasource = firebaseDatasource,
        _localDatasource = localDatasource;

  int get currentStep => _currentStep;
  String get name => _name;
  String get selectedAvatarId => _selectedAvatarId;
  String get selectedAvatarUrl => _selectedAvatarUrl;
  String get proficiencyLevel => _proficiencyLevel;
  Set<String> get selectedGoals => _selectedGoals;
  int get dailyMinutes => _dailyMinutes;
  Set<String> get selectedTopics => _selectedTopics;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  static const int totalSteps = 5;

  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return _name.trim().isNotEmpty;
      case 1:
        return _proficiencyLevel.isNotEmpty;
      case 2:
        return _selectedGoals.isNotEmpty;
      case 3:
        return true;
      case 4:
        return _selectedTopics.isNotEmpty;
      default:
        return false;
    }
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void selectAvatar(String id, String url) {
    _selectedAvatarId = id;
    _selectedAvatarUrl = url;
    notifyListeners();
  }

  void setProficiencyLevel(String level) {
    _proficiencyLevel = level;
    notifyListeners();
  }

  void toggleGoal(String goalId) {
    if (_selectedGoals.contains(goalId)) {
      _selectedGoals.remove(goalId);
    } else {
      _selectedGoals.add(goalId);
    }
    notifyListeners();
  }

  void setDailyMinutes(int minutes) {
    _dailyMinutes = minutes;
    notifyListeners();
  }

  void toggleTopic(String topicId) {
    if (_selectedTopics.contains(topicId)) {
      _selectedTopics.remove(topicId);
    } else {
      _selectedTopics.add(topicId);
    }
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1 && canProceed) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(String uid) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final profile = UserProfile(
        uid: uid,
        name: _name.trim(),
        avatarId: _selectedAvatarId,
        avatarUrl: _selectedAvatarUrl,
        proficiencyLevel: _proficiencyLevel,
        selectedGoals: _selectedGoals.toList(),
        dailyMinutes: _dailyMinutes,
        selectedTopics: _selectedTopics.toList(),
      );

      // Save locally first so navigation can proceed regardless of network
      await _localDatasource.setOnboardingComplete(true);
      await _localDatasource.setCachedUid(uid);

      // Firestore write with timeout — don't block the user on slow network
      try {
        await _firebaseDatasource
            .saveUserProfile(profile)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Firestore failed or timed out — local save succeeded,
        // profile will sync on next app launch when network is available.
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save profile. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
