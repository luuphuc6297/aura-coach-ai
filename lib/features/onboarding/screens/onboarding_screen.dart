import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/step_name_avatar.dart';
import '../widgets/step_level.dart';
import '../widgets/step_goals.dart';
import '../widgets/step_daily_time.dart';
import '../widgets/step_topics.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/progress_dots.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AppAnimations.durationNormal,
      curve: AppAnimations.easeClay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(
        firebaseDatasource: context.read(),
        localDatasource: context.read(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Consumer<OnboardingProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  ProgressDots(
                    totalSteps: OnboardingProvider.totalSteps,
                    currentStep: provider.currentStep,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        StepNameAvatar(),
                        StepLevel(),
                        StepGoals(),
                        StepDailyTime(),
                        StepTopics(),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: AppAnimations.durationNormal,
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: provider.errorMessage != null
                        ? Padding(
                            key: const ValueKey('error'),
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: ErrorBanner(message: provider.errorMessage!),
                          )
                        : const SizedBox.shrink(key: ValueKey('no-error')),
                  ),
                  _BottomButtons(
                    provider: provider,
                    pageController: _pageController,
                    onAnimateToPage: _animateToPage,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final OnboardingProvider provider;
  final PageController pageController;
  final void Function(int) onAnimateToPage;

  const _BottomButtons({
    required this.provider,
    required this.pageController,
    required this.onAnimateToPage,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep =
        provider.currentStep == OnboardingProvider.totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      child: Column(
        children: [
          ClayButton(
            text: isLastStep ? "Let's go! \u{2192}" : 'Continue \u{2192}',
            isLoading: provider.isSaving,
            onTap: provider.canProceed
                ? () async {
                    if (isLastStep) {
                      final auth = context.read<AuthProvider>();
                      final uid = auth.currentUser?.uid;
                      if (uid == null) return;
                      final success = await provider.saveProfile(uid);
                      if (success && context.mounted) {
                        auth.markOnboardingComplete();
                        context.go('/home');
                      }
                    } else {
                      provider.nextStep();
                      onAnimateToPage(provider.currentStep);
                    }
                  }
                : null,
          ),
          if (provider.currentStep > 0) ...[
            const SizedBox(height: 8),
            ClayButton(
              text: 'Back',
              variant: ClayButtonVariant.secondary,
              onTap: () {
                provider.previousStep();
                onAnimateToPage(provider.currentStep);
              },
            ),
          ],
        ],
      ),
    );
  }
}
