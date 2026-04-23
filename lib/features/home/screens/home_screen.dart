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
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../../shared/widgets/swipe_dots.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../my_library/providers/library_provider.dart';
import '../../scenario/providers/scenario_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _modeController.addListener(_onModeScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<HomeProvider>().loadProfile(uid);
        context.read<LibraryProvider>().init(uid);
      }
    });
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
        child: Column(
          children: [
            _TopBar(accentColor: _modes[_currentMode].accentColor),
            Expanded(
              child: Stack(
                children: [
                  _buildModePageView(),
                  _buildVerticalModeDots(),
                ],
              ),
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

  Widget _buildModePageView() {
    return PageView.builder(
      controller: _modeController,
      scrollDirection: Axis.vertical,
      itemCount: _modes.length,
      itemBuilder: (context, modeIndex) {
        final mode = _modes[modeIndex];
        final deepDive = modeDeepDiveList[modeIndex];

        final isRoleplay = mode.route == '/scenario';
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
            isLoading: isRoleplay && _isStartingRoleplay,
            onTap: mode.route != null
                ? () {
                    if (isRoleplay) {
                      _startRoleplay();
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
    description: 'Practice real-life situations with AI roleplay. Get instant feedback on grammar, vocabulary & tone.',
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
    description: "Learn through interactive stories. You're the main character — your choices shape the narrative.",
    iconUrl: CloudinaryAssets.modeStory,
    accentColor: AppColors.purple,
    badgeText: 'INTERACTIVE',
    ctaText: 'Begin Story',
    quotaText: '3 free stories / day',
    tags: ['📖 Narrative', '🎭 Choices'],
  ),
  _ModeConfig(
    title: 'Tone Translator',
    description: 'Master the art of tone. See how one sentence sounds formal, friendly, casual & neutral.',
    iconUrl: CloudinaryAssets.modeTranslator,
    accentColor: AppColors.gold,
    badgeText: 'UNIQUE',
    ctaText: 'Translate Now',
    quotaText: '10 free translations / day',
    tags: ['🎭 4 Tones', '🔊 TTS'],
  ),
  _ModeConfig(
    title: 'Vocab Hub',
    description: 'Deep-dive into any word. Get analysis, mind maps, examples & spaced repetition flashcards.',
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
          GestureDetector(
            onTap: () => context.push('/history'),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text('\u{1F4CB}', style: TextStyle(fontSize: 18)),
              ),
            ),
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
