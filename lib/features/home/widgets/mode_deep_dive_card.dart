import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/app_icon.dart';
import '../models/mode_deep_dive_data.dart';
import '../../../shared/widgets/clay_pressable.dart';

class ModeDeepDiveCard extends StatelessWidget {
  final ModeDeepDiveData data;
  final VoidCallback? onTap;

  const ModeDeepDiveCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.clay.background,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCompactHero(),
                _buildSeparator(context),
                if (data.steps.isNotEmpty) _buildHowItWorks(context),
                if (data.tonePreviews != null)
                  _buildTonePreviews(context)
                else if (data.features.isNotEmpty)
                  _buildFeatures(context),
                _buildCta(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: data.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: data.accentColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: CloudImage(url: data.iconUrl, size: 44),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.h1,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: data.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: data.accentColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.caption.copyWith(
                          color: data.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: context.clay.border,
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW IT WORKS',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          ...data.steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: data.accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          step.number,
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: data.accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: AppTypography.sectionTitle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.subtitle,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 13,
                              color: context.clay.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.featuresSectionTitle.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          ...data.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.clay.surface,
                    borderRadius: AppRadius.lgBorder,
                    border: Border.all(color: context.clay.border, width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: data.accentColor.withValues(alpha: 0.1),
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Center(
                          child: AppIcon(iconId: feature.iconId, size: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: AppTypography.sectionTitle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              feature.description,
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 13,
                                color: context.clay.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTonePreviews(BuildContext context) {
    final tones = data.tonePreviews!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.featuresSectionTitle.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          ...tones.map((tone) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.clay.surface,
                    borderRadius: AppRadius.lgBorder,
                    border: Border.all(color: context.clay.border, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tone.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: AppIcon(iconId: tone.iconId, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tone.label,
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: tone.color,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              tone.example,
                              style: AppTypography.caption.copyWith(
                                color: context.clay.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppIcon(iconId: 'tone_speaker', size: 14),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCta() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ClayPressable(
            onTap: onTap,
            builder: (context, isPressed) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withValues(alpha: 0.4),
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${data.ctaText} →',
                  textAlign: TextAlign.center,
                  style: AppTypography.button.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(data.quotaText, style: AppTypography.caption),
        ],
      ),
    );
  }
}
