import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_card.dart';

/// Placeholder Edit Profile screen. The full form (name, avatar, level,
/// daily-goal) lands in Phase 2; for now the route exists so the Profile tab's
/// "Edit profile" row navigates somewhere coherent instead of 404-ing.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: ClayBackButton(),
        ),
        title: Text('Edit profile', style: AppTypography.sectionTitle),
        centerTitle: true,
      ),
      body: const _ComingSoonBody(
        icon: Icons.edit_rounded,
        accent: AppColors.teal,
        title: 'Edit profile — coming soon',
        description:
            'You\'ll be able to change your name, avatar, proficiency level, '
            'and daily goal from here once Phase 2 ships.',
      ),
    );
  }
}

class _ComingSoonBody extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String description;

  const _ComingSoonBody({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.huge,
      ),
      child: ClayCard(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: AppRadius.lgBorder,
              ),
              child: Icon(icon, size: 32, color: accent),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(color: AppColors.warmDark),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
            ),
          ],
        ),
      ),
    );
  }
}
