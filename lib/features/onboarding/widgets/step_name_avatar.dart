import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/staggered_entrance.dart';

class StepNameAvatar extends StatelessWidget {
  const StepNameAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: StaggeredEntrance(
        children: [
          Center(
            child: CloudImage(
              url: CloudinaryAssets.auraOrbLarge,
              size: 100,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            context.loc.onboardingNameTitle,
            style: AppTypography.displayMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.loc.onboardingNameSubtitle,
            style: AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ClayTextInput(
            onChanged: provider.setName,
            hintText: context.loc.onboardingNameHint,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            context.loc.onboardingBuddyLabel,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: context.clay.textFaint,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: avatarOptions.map((avatar) {
              final isSelected = provider.selectedAvatarId == avatar.id;
              return ClayPressable(
                onTap: () => provider.selectAvatar(avatar.id, avatar.url),
                scaleDown: 0.90,
                builder: (context, isPressed) {
                  return Transform.scale(
                    scale: isSelected ? 1.15 : 1.0,
                    child: AnimatedContainer(
                      duration: AppAnimations.durationMedium,
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal
                              : context.clay.border,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.teal.withValues(alpha: 0.25),
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                ),
                                ...AppShadows.clay(context),
                              ]
                            : AppShadows.card(context),
                      ),
                      child: ClipOval(
                        child: CloudImage(url: avatar.url, size: 60),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
