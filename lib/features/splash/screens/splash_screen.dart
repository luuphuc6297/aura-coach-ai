import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
          parent: _floatingController, curve: AppAnimations.easeClay),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationPulse,
    )..repeat(reverse: true);

    _glowScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _glowController, curve: AppAnimations.easeClay),
    );

    _glowOpacity = Tween<double>(begin: 0.15, end: 0.3).animate(
      CurvedAnimation(parent: _glowController, curve: AppAnimations.easeClay),
    );

    _initAndRedirect();
  }

  Future<void> _initAndRedirect() async {
    final auth = context.read<AuthProvider>();
    try {
      await auth.initialize();
    } catch (_) {
      // Initialization failed (e.g. Firestore unavailable).
      // Continue with whatever state we have from the local cache.
    }
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (auth.status == AuthStatus.unauthenticated) {
      context.go('/auth');
    } else if (!auth.hasCompletedOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final reduceMotion = AppAnimations.shouldReduceMotion(context);
                final scale = reduceMotion ? 1.0 : _glowScale.value;
                final opacity = reduceMotion ? 0.15 : _glowOpacity.value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.teal.withValues(alpha: opacity),
                          AppColors.teal.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.7],
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: child,
                );
              },
              child: SizedBox(
                width: 180,
                height: 180,
                child: Center(
                  child: CloudImage(
                    url: CloudinaryAssets.auraOrbLarge,
                    size: 160,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
