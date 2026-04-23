import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/clay_pressable.dart';

/// Action returned from [showStartStorySheet]. Either indicates the user
/// wants to resume a specific story conversation (with [conversationId]) or
/// start fresh by browsing the Story library.
class StartStoryAction {
  final String? conversationId;

  const StartStoryAction.newStory() : conversationId = null;
  const StartStoryAction.resume(String id) : conversationId = id;

  bool get isResume => conversationId != null;
}

/// Shows the Start Story bottom sheet. Returns `null` when dismissed,
/// [StartStoryAction.newStory] when the user wants to browse the library,
/// or [StartStoryAction.resume] when they pick an in-progress story.
///
/// [storyLimit] is the per-day cap for the user's tier (`-1` = unlimited).
/// [storiesUsedToday] drives the quota badge and disabled state when the
/// user has no stories left for the day.
Future<StartStoryAction?> showStartStorySheet({
  required BuildContext context,
  required List<Map<String, dynamic>> conversations,
  required int storyLimit,
  required int storiesUsedToday,
}) {
  return showModalBottomSheet<StartStoryAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _StartStorySheet(
      conversations: conversations,
      storyLimit: storyLimit,
      storiesUsedToday: storiesUsedToday,
    ),
  );
}

class _StartStorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final int storyLimit;
  final int storiesUsedToday;

  const _StartStorySheet({
    required this.conversations,
    required this.storyLimit,
    required this.storiesUsedToday,
  });

  bool get _isUnlimited => storyLimit < 0;
  int get _storiesLeft =>
      _isUnlimited ? -1 : (storyLimit - storiesUsedToday).clamp(0, storyLimit);
  bool get _quotaExhausted => !_isUnlimited && _storiesLeft <= 0;

  String get _quotaLabel {
    if (_isUnlimited) return 'Unlimited today';
    return '$_storiesLeft of $storyLimit left today';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        border: Border.all(color: AppColors.clayBorder, width: 2),
        boxShadow: AppShadows.card,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.clayBorder,
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Begin a Story',
                          style: AppTypography.title.copyWith(
                            color: AppColors.warmDark,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Continue a story in progress or browse the library.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.warmMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuotaBadge(
                    label: _quotaLabel,
                    exhausted: _quotaExhausted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _BrowseLibraryCta(
                disabled: _quotaExhausted,
                onTap: _quotaExhausted
                    ? null
                    : () => Navigator.of(context).pop(
                          const StartStoryAction.newStory(),
                        ),
              ),
              if (conversations.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'In Progress',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (_quotaExhausted) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• Disabled until tomorrow',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warmMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = conversations[index];
                      return _ResumeStoryCard(
                        data: item,
                        disabled: _quotaExhausted,
                        onTap: _quotaExhausted
                            ? null
                            : () {
                                final id = item['conversationId'] as String? ??
                                    item['id'] as String?;
                                if (id == null) return;
                                Navigator.of(context)
                                    .pop(StartStoryAction.resume(id));
                              },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  final String label;
  final bool exhausted;

  const _QuotaBadge({required this.label, required this.exhausted});

  @override
  Widget build(BuildContext context) {
    final Color bg = exhausted
        ? AppColors.warmMuted.withValues(alpha: 0.18)
        : AppColors.purple.withValues(alpha: 0.16);
    final Color fg = exhausted ? AppColors.warmMuted : AppColors.purpleDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BrowseLibraryCta extends StatelessWidget {
  final VoidCallback? onTap;
  final bool disabled;

  const _BrowseLibraryCta({required this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: ClayPressable(
        onTap: disabled ? null : onTap,
        scaleDown: 0.97,
        builder: (context, isPressed) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: disabled
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.purple,
                        AppColors.purpleDeep,
                      ],
                    ),
              color:
                  disabled ? AppColors.warmMuted.withValues(alpha: 0.22) : null,
              borderRadius: AppRadius.lgBorder,
              border: disabled
                  ? Border.all(color: AppColors.clayBorder, width: 1.5)
                  : null,
              boxShadow: disabled
                  ? null
                  : AppShadows.colored(AppColors.purple, alpha: 0.35),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: disabled
                        ? AppColors.warmMuted.withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.22),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: disabled ? AppColors.warmMuted : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse Stories',
                        style: AppTypography.title.copyWith(
                          color: disabled ? AppColors.warmMuted : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        disabled
                            ? 'Available again tomorrow'
                            : 'Featured library or craft your own',
                        style: AppTypography.caption.copyWith(
                          color: disabled
                              ? AppColors.warmMuted
                              : Colors.white.withValues(alpha: 0.92),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  disabled
                      ? Icons.lock_outline_rounded
                      : Icons.arrow_forward_rounded,
                  color: disabled ? AppColors.warmMuted : Colors.white,
                  size: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResumeStoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final bool disabled;

  const _ResumeStoryCard({
    required this.data,
    required this.onTap,
    this.disabled = false,
  });

  String _formatRelative(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.month}/${date.day}';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] as String? ?? '').trim();
    final topic = (data['topic'] as String? ?? '').trim();
    final level = (data['level'] as String? ?? '').trim();
    final updatedAt = data['updatedAt'] as String? ??
        data['startedAt'] as String? ??
        data['createdAt'] as String?;

    final character = data['character'];
    final characterName = character is Map<String, dynamic>
        ? (character['name'] as String? ?? '')
        : '';
    final characterInitial = character is Map<String, dynamic>
        ? (character['initial'] as String? ?? '?')
        : '?';

    final turnsValue = data['userTurnCount'] ??
        (data['turns'] as List<dynamic>?)
            ?.where((t) => t is Map<String, dynamic> && t['role'] == 'user')
            .length ??
        0;
    final turns = turnsValue is int
        ? turnsValue
        : (turnsValue is num ? turnsValue.toInt() : 0);

    final displayTitle =
        title.isNotEmpty ? title : (topic.isNotEmpty ? topic : 'Story');

    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: ClayPressable(
        onTap: disabled ? null : onTap,
        scaleDown: 0.97,
        builder: (context, isPressed) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: AppColors.clayBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: disabled
                        ? null
                        : LinearGradient(
                            colors: [AppColors.purple, AppColors.purpleDeep],
                          ),
                    color: disabled
                        ? AppColors.warmMuted.withValues(alpha: 0.25)
                        : null,
                    borderRadius: AppRadius.smBorder,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    characterInitial.isNotEmpty ? characterInitial : '?',
                    style: AppTypography.labelLg.copyWith(
                      color: disabled ? AppColors.warmMuted : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: AppTypography.bodySm.copyWith(
                          color: disabled
                              ? AppColors.warmMuted
                              : AppColors.warmDark,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito',
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (characterName.isNotEmpty) characterName,
                          if (level.isNotEmpty) level,
                          '$turns turns',
                          _formatRelative(updatedAt),
                        ].join(' · '),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warmMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  disabled
                      ? Icons.lock_outline_rounded
                      : Icons.play_arrow_rounded,
                  size: 24,
                  color: disabled ? AppColors.warmMuted : AppColors.purpleDeep,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
