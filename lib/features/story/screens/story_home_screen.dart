import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_dialog.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';
import '../widgets/story_card.dart';
import '../widgets/story_hero_card.dart';
import 'story_custom_form_screen.dart';

/// Entry screen for Story Mode. Shows:
/// - Featured library as a horizontal PageView of [StoryHeroCard]s
/// - A compact grid of additional stories under the hero
/// - A pinned CTA "Create your own story" at the bottom
///
/// Tapping a library card or the CTA kicks off a new Story session via
/// [StoryProvider]. No "Continue where you left off" strip here — resume is
/// surfaced from the Home entry-flow popup only (per MVP spec).
class StoryHomeScreen extends StatefulWidget {
  const StoryHomeScreen({super.key});

  @override
  State<StoryHomeScreen> createState() => _StoryHomeScreenState();
}

class _StoryHomeScreenState extends State<StoryHomeScreen> {
  final PageController _heroController = PageController(viewportFraction: 0.92);
  int _heroIndex = 0;
  // Holds the id of the story currently being started. Null means idle.
  // When set, the matching card shows a loading indicator and all other
  // featured cards are visually disabled.
  String? _startingStoryId;
  // True while a "Create your own" session is being prepared.
  bool _isStartingCustom = false;
  bool _didInit = false;

  bool get _isBusy => _startingStoryId != null || _isStartingCustom;

  @override
  void initState() {
    super.initState();
    _heroController.addListener(_onHeroScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureInitialised());
  }

  @override
  void dispose() {
    _heroController.removeListener(_onHeroScroll);
    _heroController.dispose();
    super.dispose();
  }

  void _onHeroScroll() {
    final page = _heroController.page;
    if (page == null) return;
    final rounded = page.round();
    if (rounded != _heroIndex) {
      setState(() => _heroIndex = rounded);
    }
  }

  Future<void> _ensureInitialised() async {
    if (_didInit) return;
    _didInit = true;
    final uid = context.read<AuthProvider>().currentUser?.uid;
    final profile = context.read<HomeProvider>().userProfile;
    if (uid == null) return;
    await context.read<StoryProvider>().init(
          uid: uid,
          tier: profile?.tier ?? 'free',
          level: profile?.proficiencyLevel ?? 'intermediate',
        );
  }

  Future<void> _startFromLibrary(Story story) async {
    if (_isBusy) return;
    final provider = context.read<StoryProvider>();

    if (!provider.canStartSession()) {
      _showLimitSnack();
      return;
    }

    setState(() => _startingStoryId = story.id);
    final ok = await provider.startFromLibrary(story);
    if (!mounted) return;
    setState(() => _startingStoryId = null);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not start story. Try again.'),
        ),
      );
      return;
    }
    context.push('/story/chat');
  }

  Future<void> _startCustom() async {
    if (_isBusy) return;
    final provider = context.read<StoryProvider>();
    if (!provider.canStartSession()) {
      _showLimitSnack();
      return;
    }
    setState(() => _isStartingCustom = true);
    final started = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const StoryCustomFormScreen()),
    );
    if (!mounted) return;
    setState(() => _isStartingCustom = false);
    if (started == true) context.push('/story/chat');
  }

  void _showLimitSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily limit reached. Upgrade for more stories.'),
      ),
    );
  }

  /// Confirm exit while a story is being prepared. Returns true if the user
  /// wants to leave the screen anyway (even though their daily quota has
  /// likely been consumed by now).
  Future<bool> _confirmExitWhileStarting() async {
    final result = await showClayDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogContext.clay.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          title: Text(
            'Leave now?',
            style: AppTypography.h3.copyWith(color: dialogContext.clay.text),
          ),
          content: Text(
            "We're still preparing your story. If you leave now this session will still count toward today's limit.",
            style: AppTypography.bodyMd.copyWith(
              color: dialogContext.clay.textMuted,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Stay',
                style: AppTypography.button.copyWith(
                  color: AppColors.purpleDeep,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Leave anyway',
                style: AppTypography.button.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Clears local busy flags so PopScope allows the next pop. The underlying
  /// Gemini / Firestore calls keep running in the provider; the `if (!mounted)`
  /// guards in [_startFromLibrary] / [_startCustom] prevent any navigation
  /// attempts after the user has left.
  void _releaseBusyFlags() {
    if (!mounted) return;
    setState(() {
      _startingStoryId = null;
      _isStartingCustom = false;
    });
  }

  Future<void> _handleBack() async {
    if (_isBusy) {
      final confirmed = await _confirmExitWhileStarting();
      if (!mounted || !confirmed) return;
      _releaseBusyFlags();
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final stories = provider.featuredLibrary;
    final heroStories = stories.take(4).toList();
    final gridStories =
        stories.length > 4 ? stories.sublist(4) : const <Story>[];

    return PopScope<Object?>(
      canPop: !_isBusy,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await _confirmExitWhileStarting();
        if (!mounted || !confirmed) return;
        _releaseBusyFlags();
        // State now allows pop on next frame; trigger it explicitly.
        if (mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: context.clay.background,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                onBack: _handleBack,
                quotaText: '${provider.storyUsedToday} used today',
              ),
              Expanded(
                child: provider.isLoading && stories.isEmpty
                    ? const _LoadingState()
                    : stories.isEmpty
                        ? _EmptyState(
                            message: provider.error ??
                                'No stories available yet. Try again later.',
                            onRetry: () => provider.refreshLibrary(),
                          )
                        : _buildLibrary(provider, heroStories, gridStories),
              ),
              _CreateOwnCta(
                isLoading: _isStartingCustom,
                disabled: _startingStoryId != null,
                onTap: _startCustom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibrary(
    StoryProvider provider,
    List<Story> heroStories,
    List<Story> gridStories,
  ) {
    final otherLevels = provider.otherLevels;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: _SectionHeader(
            title: 'Featured Stories',
            subtitle: 'Curated for your level. Tap any card to begin.',
          ),
        ),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _heroController,
            itemCount: heroStories.length,
            itemBuilder: (context, i) {
              final story = heroStories[i];
              final isThisStarting = _startingStoryId == story.id;
              final isAnotherBusy = _isBusy && !isThisStarting;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StoryHeroCard(
                  story: story,
                  isLoading: isThisStarting,
                  disabled: isAnotherBusy,
                  onTap: () => _startFromLibrary(story),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _HeroDots(total: heroStories.length, current: _heroIndex),
        if (gridStories.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: _SectionHeader(
              title: 'More Stories',
              subtitle: 'Different topics and characters to explore.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gridStories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                final story = gridStories[i];
                final isThisStarting = _startingStoryId == story.id;
                final isAnotherBusy = _isBusy && !isThisStarting;
                return StoryCard(
                  story: story,
                  isLoading: isThisStarting,
                  disabled: isAnotherBusy,
                  onTap: () => _startFromLibrary(story),
                );
              },
            ),
          ),
        ],
        if (otherLevels.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: _SectionHeader(
              title: 'Other Levels',
              subtitle: 'Stretch up or ease back when you want a change.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: otherLevels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                final story = otherLevels[i];
                final isThisStarting = _startingStoryId == story.id;
                final isAnotherBusy = _isBusy && !isThisStarting;
                return StoryCard(
                  story: story,
                  isLoading: isThisStarting,
                  disabled: isAnotherBusy,
                  onTap: () => _startFromLibrary(story),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final String quotaText;

  const _TopBar({required this.onBack, required this.quotaText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 16, 6),
      child: Row(
        children: [
          ClayPressable(
            onTap: onBack,
            scaleDown: 0.90,
            builder: (ctx, __) => SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: ctx.clay.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Story Mode',
            style: AppTypography.h2.copyWith(color: AppColors.purpleDeep),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.14),
              borderRadius: AppRadius.fullBorder,
            ),
            child: Text(
              quotaText,
              style: AppTypography.caption.copyWith(
                color: AppColors.purpleDeep,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h3),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodySm.copyWith(
            color: context.clay.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HeroDots extends StatelessWidget {
  final int total;
  final int current;

  const _HeroDots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: active ? 22 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.purpleDeep
                  : AppColors.purple.withValues(alpha: 0.35),
              borderRadius: AppRadius.fullBorder,
            ),
          );
        }),
      ),
    );
  }
}

class _CreateOwnCta extends StatelessWidget {
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const _CreateOwnCta({
    required this.isLoading,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isInactive = isLoading || disabled;
    final cta = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ClayPressable(
        onTap: isInactive ? null : onTap,
        scaleDown: 0.97,
        builder: (_, __) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.purple, AppColors.purpleDeep],
              ),
              borderRadius: AppRadius.lgBorder,
              boxShadow: AppShadows.colored(AppColors.purple, alpha: 0.35),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Your Own Story',
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pick a topic + character, we handle the rest.',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          );
        },
      ),
    );

    return SafeArea(
      top: false,
      child: disabled
          ? IgnorePointer(child: Opacity(opacity: 0.45, child: cta))
          : cta,
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Loading stories…'),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EmptyState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📚', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
