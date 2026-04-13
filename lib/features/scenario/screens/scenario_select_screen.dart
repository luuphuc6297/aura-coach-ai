// lib/features/scenario/screens/scenario_select_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/scenario_provider.dart';

class ScenarioSelectScreen extends StatefulWidget {
  const ScenarioSelectScreen({super.key});

  @override
  State<ScenarioSelectScreen> createState() => _ScenarioSelectScreenState();
}

class _ScenarioSelectScreenState extends State<ScenarioSelectScreen> {
  String? _selectedTopic;
  String _selectedDifficulty = 'intermediate';

  static const _difficulties = ['beginner', 'intermediate', 'advanced'];

  static const _topicEmojis = {
    'travel': '✈️',
    'business': '💼',
    'social': '🥂',
    'daily': '🏠',
    'tech': '💻',
    'food': '🍽️',
    'medical': '🏥',
    'shopping': '🛍️',
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
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScenarioProvider>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Choose a Topic',
                    style: AppTypography.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  _buildTopicGrid(provider),
                  const SizedBox(height: 24),
                  Text(
                    'Difficulty Level',
                    style: AppTypography.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  _buildDifficultyRow(),
                  const SizedBox(height: 24),
                  if (provider.quotaExceeded) _buildQuotaBanner(provider),
                  const SizedBox(height: 12),
                  _buildStartButton(context, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Text('‹', style: AppTypography.h1.copyWith(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Scenario Coach',
            style: AppTypography.h2.copyWith(
              fontSize: 18,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid(ScenarioProvider provider) {
    final topics = _topicLabels.keys.toList();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: topics.map((topic) {
        final isSelected = _selectedTopic == topic;
        final emoji = _topicEmojis[topic] ?? '📌';
        final label = _topicLabels[topic] ?? topic;
        return GestureDetector(
          onTap: () => setState(() => _selectedTopic = topic),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.teal.withValues(alpha: 0.15)
                  : AppColors.clayWhite,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: isSelected ? AppColors.teal : AppColors.clayBorder,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected ? [] : AppShadows.soft,
            ),
            child: Text(
              '$emoji $label',
              style: AppTypography.labelSm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.teal : AppColors.warmDark,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyRow() {
    return Row(
      children: _difficulties.map((d) {
        final isSelected = _selectedDifficulty == d;
        final color = d == 'beginner'
            ? AppColors.success
            : d == 'intermediate'
                ? AppColors.gold
                : AppColors.error;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = d),
            child: Container(
              margin: EdgeInsets.only(
                right: d != 'advanced' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.clayWhite,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: isSelected ? color : AppColors.clayBorder,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Text(
                d[0].toUpperCase() + d.substring(1),
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : AppColors.warmMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuotaBanner(ScenarioProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You\'ve used ${provider.roleplayUsedToday}/${provider.roleplayLimitToday} sessions today. Upgrade to Pro for more!',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF9A7B3D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, ScenarioProvider provider) {
    final canStart = _selectedTopic != null && !provider.quotaExceeded;
    return GestureDetector(
      onTap: canStart
          ? () async {
              await provider.startSession(
                topic: _selectedTopic,
                difficulty: _selectedDifficulty,
              );
              if (provider.error == null && context.mounted) {
                context.push('/scenario/chat');
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: canStart
              ? AppColors.teal
              : AppColors.clayBeige,
          borderRadius: AppRadius.mdBorder,
          boxShadow: canStart
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.3),
                    offset: const Offset(3, 3),
                  ),
                ]
              : [],
        ),
        child: provider.isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              )
            : Text(
                provider.quotaExceeded ? 'Upgrade to Continue' : 'Start Practice',
                textAlign: TextAlign.center,
                style: AppTypography.labelMd.copyWith(
                  color: canStart ? Colors.white : AppColors.warmLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
