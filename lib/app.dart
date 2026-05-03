import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/page_transitions.dart';
import 'shared/widgets/bouncing_scroll_behavior.dart';
import 'data/cache/scenario_cache.dart';
import 'data/cache/story_cache.dart';
import 'data/datasources/firebase_datasource.dart';
import 'data/datasources/local_datasource.dart';
import 'data/gemini/gemini_service.dart';
import 'data/repositories/story_repository.dart';
import 'features/auth/providers/auth_provider.dart' as app;
import 'features/home/providers/home_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/insights/providers/analytics_provider.dart';
import 'features/my_library/providers/library_provider.dart';
import 'features/my_library/screens/my_library_screen.dart';
import 'features/ai_agent/providers/ai_agent_chat_provider.dart';
import 'features/ai_agent/screens/ai_agent_chat_screen.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'features/profile/providers/settings_provider.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/privacy_screen.dart';
import 'features/profile/screens/settings_screen.dart';
import 'features/profile/screens/subscription_screen.dart';
import 'features/scenario/providers/scenario_provider.dart';
import 'features/shared/providers/storage_quota_provider.dart';
import 'features/scenario/screens/scenario_chat_screen.dart';
import 'features/scenario/screens/session_summary_screen.dart';
import 'features/scenario/screens/conversation_history_screen.dart';
import 'features/story/providers/story_provider.dart';
import 'features/story/screens/story_home_screen.dart';
import 'features/story/screens/story_chat_screen.dart';
import 'features/story/screens/story_summary_screen.dart';
import 'features/grammar/data/grammar_firestore_datasource.dart';
import 'features/grammar/models/grammar_exercise.dart';
import 'features/grammar/providers/grammar_provider.dart';
import 'features/grammar/screens/grammar_hub_screen.dart';
import 'features/grammar/screens/grammar_practice_screen.dart';
import 'features/grammar/screens/grammar_summary_screen.dart';
import 'features/grammar/screens/grammar_topic_detail_screen.dart';
import 'features/grammar/services/grammar_gemini_service_impl.dart';
import 'features/subscription/providers/subscription_provider.dart';
import 'features/vocab_hub/flashcards/flashcards_provider.dart';
import 'features/vocab_hub/providers/compare_words_provider.dart';
import 'features/vocab_hub/providers/describe_word_provider.dart';
import 'features/vocab_hub/providers/mind_map_provider.dart';
import 'features/vocab_hub/screens/compare_words_screen.dart';
import 'features/vocab_hub/screens/describe_word_screen.dart';
import 'features/vocab_hub/screens/flashcards_screen.dart';
import 'features/vocab_hub/screens/learning_library_screen.dart';
import 'features/vocab_hub/screens/mind_map_library_screen.dart';
import 'features/vocab_hub/screens/mind_map_screen.dart';
import 'features/vocab_hub/screens/progress_dashboard_screen.dart';
import 'features/vocab_hub/screens/vocab_hub_home_screen.dart';
import 'features/vocab_hub/screens/word_analysis_screen.dart';

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
  late final StoryCache _storyCache;
  late final StoryRepository _storyRepository;
  late final app.AuthProvider _authProvider;
  late final HomeProvider _homeProvider;
  late final LibraryProvider _libraryProvider;
  late final ScenarioProvider _scenarioProvider;
  late final StoryProvider _storyProvider;
  late final AnalyticsProvider _analyticsProvider;
  late final StorageQuotaProvider _storageQuotaProvider;
  late final MindMapProvider _mindMapProvider;
  late final FlashcardsProvider _flashcardsProvider;
  late final DescribeWordProvider _describeWordProvider;
  late final CompareWordsProvider _compareWordsProvider;
  late final NotificationsProvider _notificationsProvider;
  late final AIAgentChatProvider _aiAgentChatProvider;
  late final SettingsProvider _settingsProvider;
  late final GrammarProvider _grammarProvider;
  late final SubscriptionProvider _subscriptionProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn.instance;
    _firebaseDatasource = FirebaseDatasource(db: firestore);
    _geminiService = GeminiService();
    _localDatasource = LocalDatasource(prefs: widget.prefs);
    _scenarioCache = ScenarioCache(prefs: widget.prefs);
    _storyCache = StoryCache(prefs: widget.prefs);
    _storyRepository = StoryRepository(
      firebase: _firebaseDatasource,
      cache: _storyCache,
    );

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
    _storyProvider = StoryProvider(
      gemini: _geminiService,
      firebase: _firebaseDatasource,
      local: _localDatasource,
      cache: _storyCache,
      repository: _storyRepository,
    );
    _analyticsProvider = AnalyticsProvider(
      firebase: _firebaseDatasource,
      library: _libraryProvider,
    );
    _storageQuotaProvider = StorageQuotaProvider(firebase: _firebaseDatasource);
    _mindMapProvider = MindMapProvider(
      gemini: _geminiService,
      firebase: _firebaseDatasource,
    );
    _flashcardsProvider = FlashcardsProvider(
      library: _libraryProvider,
      gemini: _geminiService,
    );
    _describeWordProvider = DescribeWordProvider(gemini: _geminiService);
    _compareWordsProvider = CompareWordsProvider(gemini: _geminiService);
    _notificationsProvider =
        NotificationsProvider(firebase: _firebaseDatasource);
    _aiAgentChatProvider = AIAgentChatProvider();
    _settingsProvider = SettingsProvider(prefs: widget.prefs);
    _grammarProvider = GrammarProvider(
      gemini: GrammarGeminiServiceImpl(),
      dataSource: GrammarFirestoreDataSource(db: firestore),
    );
    _subscriptionProvider = SubscriptionProvider();
    // Boot the SDK + listeners on next tick so this synchronous block
    // completes quickly. The provider is also self-idempotent so any
    // race against the early `Purchases.configure` in main() is fine.
    Future.microtask(() async {
      await _subscriptionProvider.configure();
      // Sync RevenueCat appUserID with the current Firebase UID so any
      // existing user (warm start with persisted auth) is immediately
      // identified to the entitlement system.
      final uid = _authProvider.currentUser?.uid;
      if (uid != null) {
        await _subscriptionProvider.login(uid);
      }
    });

    // Bind the notification log to the current Firebase user. AuthProvider
    // notifies on sign-in/out so we re-bind whenever the uid flips.
    _authProvider.addListener(_syncNotificationsUser);
    _syncNotificationsUser();

    // Keep RevenueCat's appUserID in lockstep with Firebase auth state.
    // On sign-in: rc.logIn(uid) so receipts attach to this user across
    // devices. On sign-out: rc.logOut() so the next anonymous session
    // doesn't inherit the previous user's entitlements.
    _authProvider.addListener(_syncSubscriptionUser);

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
        if (onboardingDone &&
            (path == '/auth' || path.startsWith('/onboarding'))) {
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
          path: '/story',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StoryHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/story/chat',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StoryChatScreen(),
          ),
        ),
        GoRoute(
          path: '/story/summary',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const StorySummaryScreen(),
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
        GoRoute(
          path: '/vocab-hub',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const VocabHubHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/analysis',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const WordAnalysisScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/describe',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const DescribeWordScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/flashcards',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const FlashcardsScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/library',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const LearningLibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/progress',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const ProgressDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/mind-map',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: MindMapScreen(
              seedWord: state.uri.queryParameters['seed'],
            ),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/mind-map/library',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const MindMapLibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/privacy',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const PrivacyScreen(),
          ),
        ),
        GoRoute(
          path: '/ai-agent/chat',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const AIAgentChatScreen(),
          ),
        ),
        GoRoute(
          path: '/vocab-hub/compare',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const CompareWordsScreen(),
          ),
        ),
        GoRoute(
          path: '/edit-profile',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const EditProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/subscription',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const SubscriptionScreen(),
          ),
        ),
        GoRoute(
          path: '/grammar',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: const GrammarHubScreen(),
          ),
        ),
        GoRoute(
          path: '/grammar/:topicId',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: GrammarTopicDetailScreen(
              topicId: state.pathParameters['topicId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/grammar/:topicId/practice',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: GrammarPracticeScreen(
              topicId: state.pathParameters['topicId']!,
              mode: GrammarPracticeModeId.fromId(
                state.uri.queryParameters['mode'] ?? 'translate',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/grammar/:topicId/practice/summary',
          pageBuilder: (_, state) => slideFadeTransitionPage(
            key: state.pageKey,
            child: GrammarSummaryScreen(
              topicId: state.pathParameters['topicId']!,
            ),
          ),
        ),
      ],
    );

    // Hook the notification tap → deep-link bridge. NotificationService was
    // already booted in main(); we just hand it a router callback so cold
    // and warm taps both land on the right screen.
    NotificationService.instance.onSelectPayload = (payload) {
      try {
        _router.push(payload.route);
      } catch (e) {
        debugPrint('AuraCoachApp: notification deep-link failed for '
            '"${payload.route}": $e');
      }
    };
  }

  void _syncNotificationsUser() {
    _notificationsProvider.bindUser(_authProvider.currentUser?.uid);
  }

  /// Last UID we pushed to RevenueCat — guards against re-issuing
  /// `logIn` for the same user when AuthProvider notifies about
  /// unrelated changes (e.g. onboarding flag flip).
  String? _lastRcUid;
  void _syncSubscriptionUser() {
    final uid = _authProvider.currentUser?.uid;
    if (uid == _lastRcUid) return;
    _lastRcUid = uid;
    if (uid == null) {
      _subscriptionProvider.logout();
    } else {
      _subscriptionProvider.login(uid);
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_syncNotificationsUser);
    _authProvider.removeListener(_syncSubscriptionUser);
    _authProvider.dispose();
    _homeProvider.dispose();
    _libraryProvider.dispose();
    _scenarioProvider.dispose();
    _storyProvider.dispose();
    _analyticsProvider.dispose();
    _storageQuotaProvider.dispose();
    _mindMapProvider.dispose();
    _flashcardsProvider.dispose();
    _describeWordProvider.dispose();
    _compareWordsProvider.dispose();
    _notificationsProvider.dispose();
    _aiAgentChatProvider.dispose();
    _settingsProvider.dispose();
    _grammarProvider.dispose();
    _subscriptionProvider.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseDatasource>.value(value: _firebaseDatasource),
        Provider<GeminiService>.value(value: _geminiService),
        Provider<LocalDatasource>.value(value: _localDatasource),
        ChangeNotifierProvider<app.AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<HomeProvider>.value(value: _homeProvider),
        ChangeNotifierProvider<LibraryProvider>.value(value: _libraryProvider),
        ChangeNotifierProvider<ScenarioProvider>.value(
            value: _scenarioProvider),
        ChangeNotifierProvider<StoryProvider>.value(value: _storyProvider),
        ChangeNotifierProvider<AnalyticsProvider>.value(
            value: _analyticsProvider),
        ChangeNotifierProvider<StorageQuotaProvider>.value(
            value: _storageQuotaProvider),
        ChangeNotifierProvider<MindMapProvider>.value(value: _mindMapProvider),
        ChangeNotifierProvider<FlashcardsProvider>.value(
            value: _flashcardsProvider),
        ChangeNotifierProvider<DescribeWordProvider>.value(
            value: _describeWordProvider),
        ChangeNotifierProvider<CompareWordsProvider>.value(
            value: _compareWordsProvider),
        ChangeNotifierProvider<NotificationsProvider>.value(
            value: _notificationsProvider),
        ChangeNotifierProvider<AIAgentChatProvider>.value(
            value: _aiAgentChatProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: _settingsProvider),
        ChangeNotifierProvider<GrammarProvider>.value(value: _grammarProvider),
        ChangeNotifierProvider<SubscriptionProvider>.value(
            value: _subscriptionProvider),
      ],
      child: ScrollConfiguration(
        behavior: const BouncingScrollBehavior(),
        // Watch SettingsProvider so a theme switch from Settings rebuilds
        // MaterialApp with the new themeMode immediately.
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) => MaterialApp.router(
            title: 'Aura Coach AI',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            // Locale binding — when SettingsProvider.language is 'en' or 'vi'
            // we force that locale; null means follow the system locale.
            locale: _localeFromCode(settings.language),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('vi'),
            ],
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

/// Maps the SettingsProvider language code to a Flutter [Locale]. Returns
/// null when the user picks "system" so the platform locale wins.
Locale? _localeFromCode(String code) {
  switch (code) {
    case 'vi':
      return const Locale('vi');
    case 'en':
      return const Locale('en');
    default:
      return null;
  }
}
