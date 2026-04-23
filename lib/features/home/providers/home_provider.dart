import 'package:flutter/foundation.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../domain/entities/user_profile.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseDatasource _firebaseDatasource;

  UserProfile? _userProfile;
  bool _isLoading = false;

  HomeProvider({required FirebaseDatasource firebaseDatasource})
      : _firebaseDatasource = firebaseDatasource;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    _userProfile = await _firebaseDatasource.getUserProfile(uid);
    _isLoading = false;
    notifyListeners();
  }
}
