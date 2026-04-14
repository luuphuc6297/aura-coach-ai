import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class LessonCard extends StatelessWidget {
  final String vietnameseSentence;
  final String topic;
  final String difficulty;
  final int scenarioIndex;
  final bool isVnToEn;
  final String title;
  final String situation;
  final VoidCallback? onHint;
  final VoidCallback? onToggleDirection;

  const LessonCard({
    super.key,
    required this.vietnameseSentence,
    required this.topic,
    required this.difficulty,
    required this.scenarioIndex,
    required this.isVnToEn,
    this.title = '',
    this.situation = '',
    this.onHint,
    this.onToggleDirection,
  });

  static const _topicEmojis = {
    'travel': '✈️',
    'business': '💼',
    'social': '🥂',
    'daily': '🏠',
    'tech': '💻',
    'food': '🍽️',
    'medical': '🏥',
    'shopping': '🛍️',
    'entertainment': '🎬',
    'sports': '⚽',
    'education': '🎓',
    'environment': '🌿',
    'finance': '💰',
    'relationships': '❤️',
    'legal': '⚖️',
    'property': '🔑',
  };

  static const _topicLabels = {
    'travel': 'Travel',
    'business': 'Business',
    'social': 'Social',
    'daily': 'Daily Life',
    'tech': 'Technology',
    'food': 'Food & Dining',
    'medical': 'Medical',
    'shopping': 'Shopping',
    'entertainment': 'Entertainment',
    'sports': 'Sports',
    'education': 'Education',
    'environment': 'Environment',
    'finance': 'Finance',
    'relationships': 'Relationships',
    'legal': 'Legal',
    'property': 'Property',
  };

  String get _topicEmoji => _topicEmojis[topic] ?? '📌';

  String get _topicLabel => _topicLabels[topic] ?? 'Scenario';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.clayBorder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$_topicEmoji $_topicLabel',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Scenario #$scenarioIndex',
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF9A7B3D),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTypography.h2.copyWith(
                fontSize: 20,
                color: AppColors.warmDark,
                height: 1.2,
              ),
            ),
          ],
          if (situation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: AppRadius.mdBorder,
                border: Border(
                  left: BorderSide(color: AppColors.teal, width: 3),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.warmMuted,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  children: [
                    TextSpan(
                      text: 'Situation: ',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    TextSpan(text: situation),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            isVnToEn ? 'TRANSLATE TO ENGLISH' : 'TRANSLATE TO VIETNAMESE',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: AppRadius.mdBorder,
              border: Border(
                left: BorderSide(color: AppColors.teal, width: 4),
              ),
              boxShadow: AppShadows.soft,
            ),
            child: Text(
              '"$vietnameseSentence"',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.5,
                color: AppColors.warmDark,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                    color: _getDifficultyColor().withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  difficulty,
                  style: AppTypography.labelSm.copyWith(
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onHint,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '💡 Need Help?',
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
                onTap: onToggleDirection,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '🔄 ${isVnToEn ? 'EN↔VN' : 'VN↔EN'}',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    final lower = difficulty.toLowerCase();
    if (lower.contains('easy') || lower.contains('beginner')) {
      return AppColors.success;
    } else if (lower.contains('hard') || lower.contains('advanced')) {
      return AppColors.error;
    } else {
      return AppColors.gold;
    }
  }
}
