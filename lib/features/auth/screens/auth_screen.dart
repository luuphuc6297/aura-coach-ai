import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/aura_logo.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  static const _itemCount = 5;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationStagger,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Animation<double> _fadeFor(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Widget _staggered(int index, Widget child) {
    if (AppAnimations.shouldReduceMotion(context)) return child;
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Opacity(
          opacity: _fadeFor(index).value,
          child: Transform.translate(
            offset: _slideFor(index).value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _staggered(0, const AuraLogo(fontSize: 64)),
                          const SizedBox(height: AppSpacing.lg),
                          _staggered(
                            1,
                            Text(
                              'Your personal AI English coach.\nLearn naturally, speak confidently.',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.warmMuted,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xxl,
                    right: AppSpacing.xxl,
                    bottom: AppSpacing.sm,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _staggered(
                          2,
                          AuthButton(
                            text: 'Continue with Google',
                            icon: const _GoogleIcon(),
                            style: AuthButtonVariant.google,
                            isLoading: auth.isMethodLoading(AuthMethod.google),
                            onTap: auth.isAnyLoading
                                ? null
                                : () => auth.signInWithGoogle(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _staggered(
                          3,
                          AuthButton(
                            text: 'Continue with Apple',
                            icon: Icon(
                              Icons.apple,
                              size: 20,
                              color: AppColors.white,
                            ),
                            style: AuthButtonVariant.apple,
                            isLoading: auth.isMethodLoading(AuthMethod.apple),
                            onTap: auth.isAnyLoading
                                ? null
                                : () => auth.signInWithApple(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _staggered(
                          4,
                          AuthButton(
                            text: 'Try as Guest',
                            icon: const AppIcon(
                                iconId: AppIcons.profile, size: 20),
                            style: AuthButtonVariant.guest,
                            isLoading: auth.isMethodLoading(AuthMethod.guest),
                            onTap: auth.isAnyLoading
                                ? null
                                : () => auth.continueAsGuest(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _staggered(
                          4,
                          Text(
                            'By continuing you agree to our\nTerms of Service and Privacy Policy',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
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
                          child: auth.errorMessage != null
                              ? Padding(
                                  key: const ValueKey('error'),
                                  padding:
                                      const EdgeInsets.only(top: AppSpacing.xl),
                                  child: ErrorBanner(
                                    message: auth.errorMessage!,
                                    onDismiss: auth.clearError,
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('no-error')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(w * 0.94, h * 0.51)
      ..cubicTo(w * 0.94, h * 0.48, w * 0.937, h * 0.44, w * 0.932, h * 0.417)
      ..lineTo(w * 0.5, h * 0.417)
      ..lineTo(w * 0.5, h * 0.594)
      ..lineTo(w * 0.747, h * 0.594)
      ..cubicTo(
          w * 0.735, h * 0.665, w * 0.697, h * 0.725, w * 0.655, h * 0.763)
      ..lineTo(w * 0.804, h * 0.878)
      ..cubicTo(w * 0.89, h * 0.798, w * 0.94, h * 0.68, w * 0.94, h * 0.51);
    canvas.drawPath(bluePath, bluePaint);

    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(w * 0.5, h * 0.958)
      ..cubicTo(
          w * 0.624, h * 0.958, w * 0.727, h * 0.917, w * 0.804, h * 0.847)
      ..lineTo(w * 0.655, h * 0.732)
      ..cubicTo(w * 0.614, h * 0.76, w * 0.562, h * 0.776, w * 0.5, h * 0.776)
      ..cubicTo(w * 0.381, h * 0.776, w * 0.28, h * 0.695, w * 0.243, h * 0.587)
      ..lineTo(w * 0.091, h * 0.705)
      ..cubicTo(w * 0.166, h * 0.855, w * 0.321, h * 0.958, w * 0.5, h * 0.958);
    canvas.drawPath(greenPath, greenPaint);

    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(w * 0.243, h * 0.587)
      ..cubicTo(w * 0.234, h * 0.56, w * 0.228, h * 0.53, w * 0.228, h * 0.5)
      ..cubicTo(w * 0.228, h * 0.47, w * 0.234, h * 0.44, w * 0.243, h * 0.413)
      ..lineTo(w * 0.091, h * 0.295)
      ..cubicTo(w * 0.042, h * 0.39, w * 0.042, h * 0.5, w * 0.042, h * 0.5)
      ..cubicTo(
          w * 0.042, h * 0.574, w * 0.059, h * 0.644, w * 0.091, h * 0.705)
      ..lineTo(w * 0.243, h * 0.587);
    canvas.drawPath(yellowPath, yellowPaint);

    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(w * 0.5, h * 0.224)
      ..cubicTo(
          w * 0.567, h * 0.224, w * 0.627, h * 0.247, w * 0.675, h * 0.292)
      ..lineTo(w * 0.806, h * 0.161)
      ..cubicTo(w * 0.727, h * 0.087, w * 0.624, h * 0.042, w * 0.5, h * 0.042)
      ..cubicTo(
          w * 0.321, h * 0.042, w * 0.166, h * 0.145, w * 0.091, h * 0.295)
      ..lineTo(w * 0.243, h * 0.413)
      ..cubicTo(w * 0.28, h * 0.305, w * 0.381, h * 0.224, w * 0.5, h * 0.224);
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
