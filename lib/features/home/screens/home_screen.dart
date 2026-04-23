import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/mode_card.dart';
import '../widgets/mode_deep_dive_card.dart';
import '../widgets/mode_horizontal_pager.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/mode_deep_dive_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../../shared/widgets/swipe_dots.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../my_library/providers/library_provider.dart';
import '../../my_library/screens/my_library_screen.dart';
import '../../scenario/providers/scenario_provider.dart';
import '../../shared/providers/storage_quota_provider.dart';
import '../../story/providers/story_provider.dart';
import '../../../shared/widgets/storage_quota_banner.dart';
import '../../profile/screens/profile_screen.dart';
import '../../insights/providers/analytics_provider.dart';
import '../../insights/screens/insights_screen.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../widgets/start_practice_sheet.dart';
import '../widgets/start_story_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final PageController _modeController = PageController();
  int _currentMode = 0;
  bool _isStartingRoleplay = false;
  bool _isStartingStory = false;

  @override
  void initState() {
    super.initState();
    _modeController.addListener(_onModeScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid == null) return;
      context.read<HomeProvider>().loadProfile(uid);
      context.read<LibraryProvider>().init(uid);
      context.read<AnalyticsProvider>().init(uid);
      // loadProfile is async; wait a microtask so `userProfile` is populated
      // before we read the tier. Falls back to 'free' if still loading — the
      // banner will self-correct on the next refresh tick.
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      final tier = context.read<HomeProvider>().userProfile?.tier ?? 'free';
      await context.read<StorageQuotaProvider>().init(uid: uid, tier: tier);
    });
  }

  /// Returns true if the user can create a new conversation. Shows a
  /// snackbar and returns false when storage is capped. Resume paths do
  /// NOT call this — they don't create a new doc.
  bool _guardStorageForNewSession() {
    final snapshot = context.read<StorageQuotaProvider>().snapshot;
    if (snapshot.canCreate) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Storage full. Delete a conversation or upgrade to start a new one.',
        ),
        action: SnackBarAction(
          label: 'Upgrade',
          onPressed: _openUpgradePage,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    return false;
  }

  void _openUpgradePage() {
    // Hook: once the paywall screen ships, switch to context.push('/upgrade').
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paywall coming soon.')),
    );
  }

  Future<void> _startRoleplay() async {
    if (_isStartingRoleplay) return;
    setState(() => _isStartingRoleplay = true);

    final authProvider = context.read<AuthProvider>();
    final profile = context.read<HomeProvider>().userProfile;
    final scenarioProvider = context.read<ScenarioProvider>();
    final uid = authProvider.currentUser?.uid ?? '';

    try {
      await scenarioProvider.init(
        uid: uid,
        tier: profile?.tier ?? 'free',
        topics: profile?.selectedTopics ?? ['travel', 'business', 'food'],
        level: profile?.proficiencyLevel ?? 'intermediate',
      );

      if (!scenarioProvider.canStartSession()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily limit reached. Upgrade for more sessions.'),
            ),
          );
        }
        return;
      }

      final conversations = await scenarioProvider.loadUserConversations();
      if (!mounted) return;

      final inProgress = conversations
          .where((c) => (c['status'] as String? ?? '') != 'completed')
          .toList();

      // Surface the popup only when there is something to resume. For a
      // first-time user or someone who has no in-progress sessions, jump
      // straight into a new session to preserve the existing frictionless flow.
      final StartPracticeAction? choice;
      if (inProgress.isEmpty) {
        choice = const StartPracticeAction.newSession();
      } else {
        choice = await showStartPracticeSheet(
          context: context,
          conversations: inProgress,
        );
      }
      if (!mounted || choice == null) return;

      if (choice.isResume) {
        final ok =
            await scenarioProvider.resumeConversation(choice.conversationId!);
        if (!mounted) return;
        if (!ok || scenarioProvider.currentScenario == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                scenarioProvider.error ?? 'Could not resume conversation.',
              ),
            ),
          );
          return;
        }
        context.push('/scenario');
        return;
      }

      // New session path — storage gate fires here (resume already returned).
      if (!_guardStorageForNewSession()) return;

      await scenarioProvider.startSession();
      if (!mounted) return;
      if (scenarioProvider.error != null ||
          scenarioProvider.currentScenario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scenarioProvider.error ?? 'Could not start session. Try again.',
            ),
          ),
        );
        return;
      }

      // Invalidate so the next quota refresh picks up the new doc.
      context.read<StorageQuotaProvider>().invalidate();
      context.push('/scenario');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingRoleplay = false);
    }
  }

  Future<void> _startStory() async {
    if (_isStartingStory) return;
    setState(() => _isStartingStory = true);

    final authProvider = context.read<AuthProvider>();
    final profile = context.read<HomeProvider>().userProfile;
    final storyProvider = context.read<StoryProvider>();
    final uid = authProvider.currentUser?.uid ?? '';

    try {
      await storyProvider.init(
        uid: uid,
        tier: profile?.tier ?? 'free',
        level: profile?.proficiencyLevel ?? 'intermediate',
      );

      // No quota gate here — the entry sheet must always open so the user
      // can see what's in progress and how many stories they have left.
      // Quota is enforced at the actual session-start points: resume action
      // below and the library/custom CTAs inside StoryHomeScreen.

      final conversations = await storyProvider.loadUserStoryConversations();
      if (!mounted) return;

      // Skip the bottom sheet only when there is nothing to resume AND the
      // user still has quota to start a fresh story — in that case we can
      // navigate straight to the library. Otherwise we always surface the
      // sheet so the quota badge + disabled states are visible.
      final StartStoryAction? choice;
      if (conversations.isEmpty && storyProvider.canStartSession()) {
        choice = const StartStoryAction.newStory();
      } else if (conversations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily limit reached. Upgrade for more stories.'),
          ),
        );
        return;
      } else {
        choice = await showStartStorySheet(
          context: context,
          conversations: conversations,
          storyLimit: storyProvider.storyLimit,
          storiesUsedToday: storyProvider.storyUsedToday,
        );
      }
      if (!mounted || choice == null) return;

      if (choice.isResume) {
        // Resume still consumes AI evaluate-turn calls during the chat,
        // so we gate it on the daily quota to prevent abuse of a single
        // session stretched across many days of replies.
        if (!storyProvider.canStartSession()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily limit reached. Upgrade for more stories.'),
            ),
          );
          return;
        }
        final ok = await storyProvider.resumeSession(choice.conversationId!);
        if (!mounted) return;
        if (!ok || storyProvider.activeSession == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                storyProvider.error ?? 'Could not resume that story.',
              ),
            ),
          );
          return;
        }
        context.push('/story/chat');
        return;
      }

      // New story path — storage gate fires here (resume already returned).
      if (!_guardStorageForNewSession()) return;
      context.read<StorageQuotaProvider>().invalidate();
      context.push('/story');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingStory = false);
    }
  }

  void _onModeScroll() {
    if (_modeController.page != null) {
      final newMode = _modeController.page!.round();
      if (newMode != _currentMode) {
        setState(() => _currentMode = newMode);
      }
    }
  }

  @override
  void dispose() {
    _modeController.removeListener(_onModeScroll);
    _modeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        // IndexedStack keeps each tab's state alive (scroll position, in-flight
        // network calls, filter selections) so switching tabs doesn't blow
        // away work-in-progress.
        child: IndexedStack(
          index: _navIndex,
          children: [
            _buildHomeTab(),
            const MyLibraryScreen(embedded: true),
            const InsightsScreen(),
            ProfileScreen(
              onOpenInsights: () => setState(() => _navIndex = 2),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<StorageQuotaProvider>(
      builder: (context, quota, _) {
        final snap = quota.snapshot;
        return Column(
          children: [
            _TopBar(accentColor: _modes[_currentMode].accentColor),
            if (snap.state != StorageQuotaState.healthy)
              StorageQuotaBanner(
                snapshot: snap,
                onManage: () => context.push('/history'),
                onUpgrade: _openUpgradePage,
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildModePageView(),
                  _buildVerticalModeDots(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModePageView() {
    return PageView.builder(
      controller: _modeController,
      scrollDirection: Axis.vertical,
      itemCount: _modes.length,
      itemBuilder: (context, modeIndex) {
        final mode = _modes[modeIndex];
        final deepDive = modeDeepDiveList[modeIndex];

        final isRoleplay = mode.route == '/scenario';
        final isStory = mode.route == '/story';
        return ModeHorizontalPager(
          accentColor: mode.accentColor,
          overviewCard: ModeCard(
            title: mode.title,
            description: mode.description,
            iconUrl: mode.iconUrl,
            accentColor: mode.accentColor,
            badgeText: mode.badgeText,
            ctaText: mode.ctaText,
            quotaText: mode.quotaText,
            tags: mode.tags,
            isLoading: (isRoleplay && _isStartingRoleplay) ||
                (isStory && _isStartingStory),
            onTap: mode.route != null
                ? () {
                    if (isRoleplay) {
                      _startRoleplay();
                    } else if (isStory) {
                      _startStory();
                    } else {
                      context.push(mode.route!);
                    }
                  }
                : null,
          ),
          deepDiveCard: ModeDeepDiveCard(data: deepDive),
        );
      },
    );
  }

  Widget _buildVerticalModeDots() {
    final accentColor = _modes[_currentMode].accentColor;
    return Positioned(
      right: 12,
      top: 0,
      bottom: 0,
      child: Center(
        child: SwipeDots(
          total: _modes.length,
          current: _currentMode,
          activeColor: accentColor,
          axis: Axis.vertical,
        ),
      ),
    );
  }
}

const _modes = [
  _ModeConfig(
    title: 'Scenario Coach',
    description:
        'Practice real-life situations with AI roleplay. Get instant feedback on grammar, vocabulary & tone.',
    iconUrl: CloudinaryAssets.modeScenarioCoach,
    accentColor: AppColors.teal,
    badgeText: 'MOST POPULAR',
    ctaText: 'Start Practice',
    quotaText: '5 free sessions / day',
    tags: ['🎯 Roleplay', '💬 4 Tones'],
    route: '/scenario',
  ),
  _ModeConfig(
    title: 'Story Mode',
    description:
        "Learn through interactive stories. You're the main character — your choices shape the narrative.",
    iconUrl: CloudinaryAssets.modeStory,
    accentColor: AppColors.purple,
    badgeText: 'INTERACTIVE',
    ctaText: 'Begin Story',
    quotaText: '3 free stories / day',
    tags: ['📖 Narrative', '🎭 Choices'],
    route: '/story',
  ),
  _ModeConfig(
    title: 'Tone Translator',
    description:
        'Master the art of tone. See how one sentence sounds formal, friendly, casual & neutral.',
    iconUrl: CloudinaryAssets.modeTranslator,
    accentColor: AppColors.gold,
    badgeText: 'UNIQUE',
    ctaText: 'Translate Now',
    quotaText: '10 free translations / day',
    tags: ['🎭 4 Tones', '🔊 TTS'],
  ),
  _ModeConfig(
    title: 'Vocab Hub',
    description:
        'Deep-dive into any word. Get analysis, mind maps, examples & spaced repetition flashcards.',
    iconUrl: CloudinaryAssets.modeVocabHub,
    accentColor: AppColors.coral,
    badgeText: 'BUILD SKILLS',
    ctaText: 'Explore Words',
    quotaText: 'Unlimited',
    tags: ['🧠 Mind Map', '📝 Quiz'],
  ),
];

class _ModeConfig {
  final String title;
  final String description;
  final String iconUrl;
  final Color accentColor;
  final String badgeText;
  final String ctaText;
  final String quotaText;
  final List<String> tags;
  final String? route;

  const _ModeConfig({
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.accentColor,
    required this.badgeText,
    required this.ctaText,
    required this.quotaText,
    required this.tags,
    this.route,
  });
}

class _TopBar extends StatelessWidget {
  final Color accentColor;

  const _TopBar({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final profile = homeProvider.userProfile;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AuraLogo(fontSize: 16, compact: true, color: accentColor),
          const Spacer(),
          ClayPressable(
            onTap: () => context.push('/history'),
            scaleDown: 0.90,
            builder: (context, isPressed) {
              return const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AppIcon(iconId: AppIcons.history, size: 22),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          if (profile != null) ...[
            Text(
              'Hi, ${profile.name}',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warmDark,
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
                boxShadow: AppShadows.clay,
              ),
              child: ClipOval(
                child: CloudImage(url: profile.avatarUrl, size: 32),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
