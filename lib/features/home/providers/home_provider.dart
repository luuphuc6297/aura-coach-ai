import 'package:flutter/foundation.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../domain/entities/user_profile.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseDatasource _firebaseDatasource;

  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isSaving = false;

  HomeProvider({required FirebaseDatasource firebaseDatasource})
      : _firebaseDatasource = firebaseDatasource;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Cap the Firestore read so a stalled connection (e.g. P0 Security #1
      // Firebase project mismatch — iOS pointed at the legacy project)
      // doesn't pin the home screen at its skeleton state forever. Falling
      // through with a null profile is safer than hanging: the home UI
      // handles missing profile gracefully via default topics/level.
      _userProfile = await _firebaseDatasource
          .getUserProfile(uid)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[HomeProvider] loadProfile failed/timed out: $e');
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Persists profile edits made from the Edit Profile screen. Optimistically
  /// updates local state first so the Profile tab reflects changes the
  /// instant the user pops back, then writes to Firestore in the background.
  /// Throws if the write fails so the UI can surface an error snackbar.
  Future<void> updateProfile(UserProfile updated) async {
    final previous = _userProfile;
    _userProfile = updated;
    _isSaving = true;
    notifyListeners();
    try {
      await _firebaseDatasource.updateUserProfile(updated);
    } catch (e) {
      // Roll back local state so the UI doesn't lie about what's persisted.
      _userProfile = previous;
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
