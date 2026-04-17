import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_animations.dart';

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
    final directionLabel = widget.isVnToEn
        ? 'TRANSLATE TO ENGLISH'
        : 'TRANSLATE TO VIETNAMESE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: AppRadius.mdBorder,
        border: Border(
          left: BorderSide(color: AppColors.teal, width: 4),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            directionLabel,
            style: AppTypography.sentenceLabel.copyWith(
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
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
                  child: GestureDetector(
                    onTap: () =>
                        widget.onListen?.call(widget.vietnameseSentence),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Text('🔊', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
            child: Text(
              '💡 Hints',
              style: AppTypography.labelSm.copyWith(
                color: const Color(0xFF9A7B3D),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
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
            child: Text(
              '🔄 ${widget.isVnToEn ? 'EN↔VN' : 'VN↔EN'}',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
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
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w800,
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
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmMuted,
                    height: 1.5,
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
