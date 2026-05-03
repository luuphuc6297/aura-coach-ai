import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../core/utils/error_handler.dart';

enum AuthMethod { google, apple, guest }

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseDatasource _firebaseDatasource;
  final LocalDatasource _localDatasource;

  AuthMethod? _loadingMethod;
  String? _errorMessage;
  bool _hasCompletedOnboarding = false;
  bool _googleSignInInitialized = false;

  AuthProvider({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseDatasource firebaseDatasource,
    required LocalDatasource localDatasource,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firebaseDatasource = firebaseDatasource,
        _localDatasource = localDatasource;

  User? get currentUser => _auth.currentUser;
  AuthStatus get status {
    if (currentUser == null) return AuthStatus.unauthenticated;
    return AuthStatus.authenticated;
  }

  AuthMethod? get loadingMethod => _loadingMethod;
  bool isMethodLoading(AuthMethod method) => _loadingMethod == method;
  bool get isAnyLoading => _loadingMethod != null;
  String? get errorMessage => _errorMessage;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> initialize() async {
    await _ensureGoogleSignInInitialized();
    _hasCompletedOnboarding = _localDatasource.isOnboardingComplete;
    if (currentUser != null && !_hasCompletedOnboarding) {
      try {
        _hasCompletedOnboarding =
            await _firebaseDatasource.hasCompletedOnboarding(currentUser!.uid);
        if (_hasCompletedOnboarding) {
          await _localDatasource.setOnboardingComplete(true);
        }
      } catch (_) {
        // Firestore unavailable — keep local cache value and continue.
        // Will sync on next successful launch.
      }
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    try {
      await _googleSignIn.initialize();
      _googleSignInInitialized = true;
    } catch (_) {}
  }

  Future<void> signInWithGoogle() async {
    _loadingMethod = AuthMethod.google;
    _errorMessage = null;
    notifyListeners();
    try {
      await _ensureGoogleSignInInitialized();
      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
          'Google Sign-In is not supported on this platform.',
        );
      }
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      await _checkOnboarding();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _errorMessage = friendlyAuthError(e);
      }
    } catch (e) {
      _errorMessage = friendlyAuthError(e);
    }
    _loadingMethod = null;
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    _loadingMethod = AuthMethod.apple;
    _errorMessage = null;
    notifyListeners();
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      await _auth.signInWithProvider(appleProvider);
      await _checkOnboarding();
    } catch (e) {
      _errorMessage = friendlyAuthError(e);
    }
    _loadingMethod = null;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _loadingMethod = AuthMethod.guest;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInAnonymously();
      await _checkOnboarding();
    } catch (e) {
      _errorMessage = friendlyAuthError(e);
    }
    _loadingMethod = null;
    notifyListeners();
  }

  Future<void> _checkOnboarding() async {
    if (currentUser == null) return;
    try {
      _hasCompletedOnboarding =
          await _firebaseDatasource.hasCompletedOnboarding(currentUser!.uid);
      if (_hasCompletedOnboarding) {
        await _localDatasource.setOnboardingComplete(true);
        await _localDatasource.setCachedUid(currentUser!.uid);
      }
    } catch (_) {
      // Firestore unavailable — default to onboarding not complete.
      // User will see onboarding and Firestore will be retried on save.
    }
  }

  void markOnboardingComplete() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _localDatasource.clearAll();
    _hasCompletedOnboarding = false;
    notifyListeners();
  }

  /// Permanently deletes the Firebase Auth account. Returns null on success
  /// or a short error code the UI can branch on:
  ///
  /// - `'requires-recent-login'` — the user signed in too long ago for a
  ///   destructive action; UI should sign them out and prompt re-login.
  /// - `'unknown'` — generic failure (caller may show the message verbatim).
  ///
  /// Caller is responsible for wiping Firestore content first (we do not
  /// touch user-scoped collections here — that's the data layer's job).
  Future<String?> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      await user.delete();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _localDatasource.clearAll();
      _hasCompletedOnboarding = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') return 'requires-recent-login';
      _errorMessage = e.message;
      notifyListeners();
      return 'unknown';
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 'unknown';
    }
  }
}
