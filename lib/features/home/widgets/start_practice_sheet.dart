import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';

/// Action returned from [showStartPracticeSheet]. Either indicates the user
/// wants to resume a specific conversation (with [conversationId]) or start
/// fresh.
class StartPracticeAction {
  final String? conversationId;

  const StartPracticeAction.newSession() : conversationId = null;
  const StartPracticeAction.resume(String id) : conversationId = id;

  bool get isResume => conversationId != null;
}

/// Shows the Start Practice bottom sheet. Returns `null` if the user dismisses
/// it without choosing, `StartPracticeAction.newSession()` when they want a
/// brand new session, or `StartPracticeAction.resume(id)` when they tap an
/// existing in-progress conversation.
Future<StartPracticeAction?> showStartPracticeSheet({
  required BuildContext context,
  required List<Map<String, dynamic>> conversations,
}) {
  return showModalBottomSheet<StartPracticeAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _StartPracticeSheet(conversations: conversations),
  );
}

class _StartPracticeSheet extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;

  const _StartPracticeSheet({required this.conversations});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: context.clay.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        border: Border.all(color: context.clay.border, width: 2),
        boxShadow: AppShadows.card(context),
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
                    color: context.clay.border,
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Start Practice',
                style: AppTypography.title.copyWith(
                  color: context.clay.text,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick up where you left off or begin a fresh scenario.',
                style: AppTypography.bodySm.copyWith(
                  color: context.clay.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _NewConversationCta(
                onTap: () => Navigator.of(context).pop(
                  const StartPracticeAction.newSession(),
                ),
              ),
              if (conversations.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'In Progress',
                  style: AppTypography.caption.copyWith(
                    color: context.clay.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
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
                      return _ResumeCard(
                        data: item,
                        onTap: () {
                          final id = item['id'] as String?;
                          if (id == null) return;
                          Navigator.of(context)
                              .pop(StartPracticeAction.resume(id));
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

class _NewConversationCta extends StatelessWidget {
  final VoidCallback onTap;

  const _NewConversationCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.teal,
                AppColors.tealDeep,
              ],
            ),
            borderRadius: AppRadius.lgBorder,
            boxShadow: AppShadows.colored(AppColors.teal, alpha: 0.35),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Conversation',
                      style: AppTypography.title.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fresh scenario tailored to your level',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ResumeCard({required this.data, required this.onTap});

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
    final difficulty = (data['difficulty'] as String? ?? '').trim();
    final createdAt = data['createdAt'] as String?;
    final turns = (data['totalTurns'] as num?)?.toInt() ??
        ((data['turns'] as List<dynamic>?)
                ?.where((m) => m is Map<String, dynamic> && m['type'] == 'user')
                .length ??
            0);
    final displayTitle =
        title.isNotEmpty ? title : (topic.isNotEmpty ? topic : 'Roleplay');

    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.clay.background,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: context.clay.border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                ),
                child: const Center(
                  child: AppIcon(iconId: AppIcons.scenario, size: 20),
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
                        color: context.clay.text,
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
                        if (difficulty.isNotEmpty) difficulty,
                        '$turns turns',
                        _formatRelative(createdAt),
                      ].join(' · '),
                      style: AppTypography.caption.copyWith(
                        color: context.clay.textMuted,
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
                Icons.play_arrow_rounded,
                size: 24,
                color: AppColors.teal,
              ),
            ],
          ),
        );
      },
    );
  }
}
