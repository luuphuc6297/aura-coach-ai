import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../auth/providers/auth_provider.dart';

class ConversationHistoryScreen extends StatelessWidget {
  const ConversationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cream,
                border: Border(
                  bottom: BorderSide(color: AppColors.clayBorder, width: 2),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: Text('‹',
                          style: AppTypography.h1.copyWith(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Conversation History',
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: uid == null
                  ? _buildEmptyState()
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: context
                          .read<FirebaseDatasource>()
                          .getConversations(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.teal,
                            ),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return _buildEmptyState();
                        }
                        final conversations = snapshot.data!;
                        if (conversations.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final item = conversations[index];
                            return _HistoryCard(
                              topic: item['topic'] as String? ?? 'Unknown',
                              difficulty:
                                  item['difficulty'] as String? ?? '',
                              status: item['status'] as String? ?? '',
                              createdAt: item['createdAt'] as String?,
                              totalScore:
                                  (item['totalScore'] as num?)?.toDouble() ??
                                      0.0,
                              totalTurns:
                                  (item['totalTurns'] as num?)?.toInt() ?? 0,
                              duration:
                                  (item['duration'] as num?)?.toInt() ?? 0,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No conversation history yet',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.warmDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a roleplay scenario to see your history here',
            style: AppTypography.caption.copyWith(
              color: AppColors.warmMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String topic;
  final String difficulty;
  final String status;
  final String? createdAt;
  final double totalScore;
  final int totalTurns;
  final int duration;

  const _HistoryCard({
    required this.topic,
    required this.difficulty,
    required this.status,
    this.createdAt,
    required this.totalScore,
    required this.totalTurns,
    required this.duration,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      }
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = totalScore >= 8
        ? AppColors.success
        : totalScore >= 5
            ? AppColors.gold
            : AppColors.error;

    final statusColor = status == 'completed' ? AppColors.success : AppColors.gold;
    final statusLabel = status == 'completed' ? 'Completed' : 'In Progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎭', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                        color: AppColors.teal,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(createdAt)} · $difficulty',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullBorder,
                  border: Border.all(
                      color: scoreColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Text(
                  totalScore.toStringAsFixed(1),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat('${duration}m', 'Duration'),
              const SizedBox(width: 16),
              _stat('$totalTurns', 'Turns'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Row(
      children: [
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.warmDark,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.warmMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
