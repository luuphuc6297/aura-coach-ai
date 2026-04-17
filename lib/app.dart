import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/page_transitions.dart';
import 'shared/widgets/bouncing_scroll_behavior.dart';
import 'data/cache/scenario_cache.dart';
import 'data/datasources/firebase_datasource.dart';
import 'data/datasources/local_datasource.dart';
import 'data/gemini/gemini_service.dart';
import 'features/auth/providers/auth_provider.dart' as app;
import 'features/home/providers/home_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/my_library/providers/library_provider.dart';
import 'features/my_library/screens/my_library_screen.dart';
import 'features/scenario/providers/scenario_provider.dart';
import 'features/scenario/screens/scenario_chat_screen.dart';
import 'features/scenario/screens/session_summary_screen.dart';
import 'features/scenario/screens/conversation_history_screen.dart';

class AuraCoachApp extends StatefulWidget {
  final SharedPreferences prefs;

  const AuraCoachApp({super.key, required this.prefs});

  @override
  State<AuraCoachApp> createState() => _AuraCoachAppState();
}

class _AuraCoachAppState extends State<AuraCoachApp> {
  late final FirebaseDatasource _firebaseDatasource;
  late final GeminiService _geminiService;
  late final LocalDatasource _localDatasource;
  late final ScenarioCache _scenarioCache;
  late final app.AuthProvider _authProvider;
  late final HomeProvider _homeProvider;
  late final LibraryProvider _libraryProvider;
  late final ScenarioProvider _scenarioProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();
    _firebaseDatasource = FirebaseDatasource(db: firestore);
    _geminiService = GeminiService();
    _localDatasource = LocalDatasource(prefs: widget.prefs);
    _scenarioCache = ScenarioCache(prefs: widget.prefs);

    _authProvider = app.AuthProvider(
      auth: firebaseAuth,
      googleSignIn: googleSignIn,
      firebaseDatasource: _firebaseDatasource,
      localDatasource: _localDatasource,
    );

    _homeProvider = HomeProvider(firebaseDatasource: _firebaseDatasource);
    _libraryProvider = LibraryProvider(
      firebase: _firebaseDatasource,
      gemini: _geminiService,
    );
    _scenarioProvider = ScenarioProvider(
      gemini: _geminiService,
      firebase: _firebaseDatasource,
      local: _localDatasource,
      cache: _scenarioCache,
    );

    _router = GoRouter(
      refreshListenable: _authProvider,
      initialLocation: '/splash',
      redirect: (context, state) {
        final path = state.uri.path;
        if (path == '/splash') return null;

        final isLoggedIn = _authProvider.currentUser != null;
        final onboardingDone = _authProvider.hasCompletedOnboarding;

        if (!isLoggedIn) return '/auth';
        if (!onboardingDone && !path.startsWith('/onboarding')) {
          return '/onboarding';
        }
        if (onboardingDone && (path == '/auth' || path.startsWith('/onboarding'))) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (_, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/auth',
          pageBuilder: (_, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const AuthScreen(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (_, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (_, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/scenario',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const ScenarioChatScreen(),
          ),
        ),
        GoRoute(
          path: '/scenario/summary',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const SessionSummaryScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const ConversationHistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/my-library',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const MyLibraryScreen(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _homeProvider.dispose();
    _libraryProvider.dispose();
    _scenarioProvider.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseDatasource>.value(value: _firebaseDatasource),
        Provider<LocalDatasource>.value(value: _localDatasource),
        ChangeNotifierProvider<app.AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<HomeProvider>.value(value: _homeProvider),
        ChangeNotifierProvider<LibraryProvider>.value(value: _libraryProvider),
        ChangeNotifierProvider<ScenarioProvider>.value(value: _scenarioProvider),
      ],
      child: ScrollConfiguration(
        behavior: const BouncingScrollBehavior(),
        child: MaterialApp.router(
          title: 'Aura Coach AI',
          theme: AppTheme.light,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
