import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/cloud_image.dart';

class StepNameAvatar extends StatelessWidget {
  const StepNameAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CloudImage(
              url: CloudinaryAssets.auraOrbLarge,
              size: 100,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'What should we call you?',
            style: AppTypography.displayMd.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick a name and choose your avatar',
            style: AppTypography.bodyMd.copyWith(color: AppColors.warmMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.clayBeige,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: AppColors.teal, width: 2),
            ),
            child: TextField(
              onChanged: provider.setName,
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.warmLight),
                border: InputBorder.none,
                icon: const Icon(Icons.edit, size: 18, color: AppColors.warmMuted),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'CHOOSE YOUR BUDDY',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.warmLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: avatarOptions.map((avatar) {
              final isSelected = provider.selectedAvatarId == avatar.id;
              return GestureDetector(
                onTap: () => provider.selectAvatar(avatar.id, avatar.url),
                child: Transform.scale(
                  scale: isSelected ? 1.15 : 1.0,
                  child: AnimatedContainer(
                    duration: AppAnimations.durationMedium,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.teal : AppColors.clayBorder,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.teal.withValues(alpha: 0.25),
                                blurRadius: 0,
                                spreadRadius: 3,
                              ),
                              ...AppShadows.clay,
                            ]
                          : AppShadows.card,
                    ),
                    child: ClipOval(
                      child: CloudImage(url: avatar.url, size: 60),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
