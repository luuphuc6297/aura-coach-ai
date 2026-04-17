import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/widgets/fluent_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

class LessonCard extends StatefulWidget {
  final String vietnameseSentence;
  final bool isVnToEn;
  final String situation;
  final VoidCallback? onHint;
  final VoidCallback? onToggleDirection;
  final ValueChanged<String>? onListen;

  const LessonCard({
    super.key,
    required this.vietnameseSentence,
    required this.isVnToEn,
    this.situation = '',
    this.onHint,
    this.onToggleDirection,
    this.onListen,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  bool _situationExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.clayBorder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSentenceBlock(),
          if (widget.situation.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildCollapsibleSituation(),
          ],
          const SizedBox(height: 12),
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildSentenceBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: AppRadius.mdBorder,
        border: Border(
          left: BorderSide(color: AppColors.teal, width: 4),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.vietnameseSentence,
              style: widget.isVnToEn
                  ? AppTypography.sentenceVi
                  : AppTypography.sentence,
            ),
          ),
          if (widget.onListen != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: ClayPressable(
                onTap: () =>
                    widget.onListen?.call(widget.vietnameseSentence),
                scaleDown: 0.90,
                builder: (context, isPressed) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const FluentIcon(AppIcons.listen, size: 20),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onHint,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FluentIcon(AppIcons.hint, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Hints',
                  style: AppTypography.sentenceLabel.copyWith(
                    color: const Color(0xFF9A7B3D),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: widget.onToggleDirection,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: AppColors.teal.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FluentIcon(AppIcons.toggle, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.isVnToEn ? 'EN↔VN' : 'VN↔EN',
                  style: AppTypography.sentenceLabel.copyWith(
                    color: AppColors.teal,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleSituation() {
    return GestureDetector(
      onTap: () => setState(() => _situationExpanded = !_situationExpanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: AppRadius.mdBorder,
          border: Border(
            left: BorderSide(color: AppColors.teal, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Situation',
                  // 15/700 — Section title tier
                  style: AppTypography.sectionTitle.copyWith(
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _situationExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.teal,
                ),
                const Spacer(),
              ],
            ),
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  widget.situation,
                  // 13/600 — Card body tier
                  style: AppTypography.cardBody.copyWith(
                    color: AppColors.warmMuted,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _situationExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: AppAnimations.durationMedium,
            ),
          ],
        ),
      ),
    );
  }
}
