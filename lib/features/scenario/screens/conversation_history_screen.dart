import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_dialog.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/providers/storage_quota_provider.dart';
import '../providers/scenario_provider.dart';

class ConversationHistoryScreen extends StatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  State<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  String _selectedFilter = 'all';
  List<Map<String, dynamic>>? _allConversations;
  bool _isLoading = true;
  bool _hasError = false;

  // Mirrors the HTML spec filter order: All → Scenario → Story → Translator.
  // Filter values map to the `mode` string stored on each conversation doc.
  // Built at runtime so labels respect the current locale.
  List<_FilterOption> _filterOptions(BuildContext context) {
    final loc = context.loc;
    return [
      _FilterOption(
        label: loc.conversationHistoryFilterAll,
        value: 'all',
        color: AppColors.teal,
      ),
      _FilterOption(
        label: loc.conversationHistoryFilterScenario,
        value: 'roleplay',
        color: AppColors.teal,
      ),
      _FilterOption(
        label: loc.conversationHistoryFilterStory,
        value: 'story',
        color: AppColors.purple,
      ),
      if (FeatureFlags.toneTranslatorEnabled)
        _FilterOption(
          label: loc.conversationHistoryFilterTranslator,
          value: 'tone',
          color: AppColors.gold,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConversations());
  }

  Future<void> _loadConversations() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _allConversations = [];
      });
      return;
    }

    try {
      final results =
          await context.read<FirebaseDatasource>().getConversations(uid);
      if (mounted) {
        setState(() {
          _allConversations = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredConversations {
    if (_allConversations == null) return [];
    if (_selectedFilter == 'all') return _allConversations!;
    return _allConversations!
        .where((doc) => doc['mode'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.clay.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: BoxDecoration(
                color: context.clay.background,
                border: Border(
                  bottom: BorderSide(color: context.clay.border, width: 2),
                ),
              ),
              child: Row(
                children: [
                  const ClayBackButton(),
                  const SizedBox(width: 4),
                  Text(
                    context.loc.conversationHistoryTitle,
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
            _buildFilterChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    // Clay pill chips matching My Library's filter row — keeps the system
    // visual language consistent. Each chip uses the mode's accent for
    // selected state; resting state is the cream/border base.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filterOptions(context).map((filter) {
            final isSelected = _selectedFilter == filter.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ClayFilterChip(
                label: filter.label,
                accentColor: filter.color,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedFilter = filter.value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }
    if (_hasError || _allConversations == null) {
      return _buildEmptyState();
    }
    final conversations = _filteredConversations;
    if (conversations.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final item = conversations[index];
        return _HistoryCard(
          data: item,
          onTap: () => _onHistoryCardTap(item),
          onRename: () => _renameConversation(item),
          onDelete: () => _deleteConversation(item),
        );
      },
    );
  }

  Future<void> _onHistoryCardTap(Map<String, dynamic> item) async {
    final status = item['status'] as String? ?? '';
    final isCompleted = status == 'completed';
    if (isCompleted) {
      _showConversationDetail(context, item);
      return;
    }
    final conversationId = item['id'] as String?;
    if (conversationId == null) return;
    final scenarioProvider = context.read<ScenarioProvider>();
    final success = await scenarioProvider.resumeConversation(conversationId);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scenarioProvider.error ?? 'Could not resume session.'),
        ),
      );
      return;
    }
    context.push('/scenario');
  }

  Future<void> _renameConversation(Map<String, dynamic> item) async {
    final conversationId = item['id'] as String?;
    if (conversationId == null) return;
    final current = (item['title'] as String?)?.trim() ?? '';
    final controller = TextEditingController(text: current);
    final newTitle = await showClayDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.clay.surface,
        title: Text(context.loc.conversationHistoryRenameTitle,
            style: AppTypography.title),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.input,
          cursorColor: AppColors.teal,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: context.loc.conversationHistoryRenameHint,
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: ctx.clay.border, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: AppColors.teal, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.loc.commonCancel,
                style: TextStyle(color: ctx.clay.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(context.loc.commonSave,
                style: TextStyle(color: AppColors.teal)),
          ),
        ],
      ),
    );
    if (!mounted ||
        newTitle == null ||
        newTitle.isEmpty ||
        newTitle == current) {
      return;
    }
    try {
      await context
          .read<ScenarioProvider>()
          .renameConversationRecord(conversationId, newTitle);
      if (!mounted) return;
      setState(() {
        final idx =
            _allConversations?.indexWhere((c) => c['id'] == conversationId) ??
                -1;
        if (idx >= 0) {
          _allConversations![idx] = {
            ..._allConversations![idx],
            'title': newTitle,
          };
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.loc.conversationHistoryRenameFailed)),
      );
    }
  }

  Future<void> _deleteConversation(Map<String, dynamic> item) async {
    final conversationId = item['id'] as String?;
    if (conversationId == null) return;
    final confirm = await showClayDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.clay.surface,
        title: Text(context.loc.conversationHistoryDeleteTitle,
            style: AppTypography.title),
        content: Text(
          context.loc.conversationHistoryDeleteBody,
          style: AppTypography.bodySm.copyWith(color: ctx.clay.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.commonCancel,
                style: TextStyle(color: ctx.clay.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.loc.commonDelete,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await context
          .read<ScenarioProvider>()
          .deleteConversationRecord(conversationId);
      if (!mounted) return;
      // Conversation count just dropped — drop the StorageQuotaProvider TTL
      // so the Home banner reflects the new state on next focus.
      context.read<StorageQuotaProvider>().invalidate();
      setState(() {
        _allConversations?.removeWhere((c) => c['id'] == conversationId);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.loc.conversationHistoryDeleteFailed)),
      );
    }
  }

  void _showConversationDetail(
      BuildContext context, Map<String, dynamic> item) {
    final mode = item['mode'] as String? ?? 'roleplay';
    final modeStyle = _ModeStyle.from(mode);
    final loc = context.loc;
    final title = item['title'] as String? ?? '';
    final topic = item['topic'] as String? ?? loc.conversationHistoryUnknownTopic;
    final difficulty = item['difficulty'] as String? ?? '';
    final status = item['status'] as String? ?? '';
    final createdAt = item['createdAt'] as String?;
    final totalScore = (item['totalScore'] as num?)?.toDouble() ?? 0.0;
    final grammarScore = (item['grammarScore'] as num?)?.toDouble();
    final vocabScore = (item['vocabScore'] as num?)?.toDouble();
    final fluencyScore = (item['fluencyScore'] as num?)?.toDouble();
    final totalTurns = (item['totalTurns'] as num?)?.toInt() ?? 0;
    final duration = (item['duration'] as num?)?.toInt() ?? 0;

    String formattedDate = loc.conversationHistoryUnknownTopic;
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate =
            '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final isCompleted = status == 'completed';
    final scoreColor = totalScore >= 8
        ? AppColors.success
        : totalScore >= 5
            ? AppColors.gold
            : AppColors.error;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: context.clay.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          border: Border.all(color: context.clay.border, width: 2),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
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
              const SizedBox(height: 16),
              Row(
                children: [
                  AppIcon(iconId: modeStyle.iconUrl, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: AppTypography.title.copyWith(
                              color: modeStyle.color,
                            ),
                          ),
                        Text(
                          topic,
                          style: AppTypography.bodySm.copyWith(
                            color: context.clay.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _detailChip(difficulty, modeStyle.color),
                  const SizedBox(width: 8),
                  _detailChip(
                    isCompleted
                        ? loc.conversationHistoryStatusCompleted
                        : loc.conversationHistoryStatusInProgress,
                    isCompleted ? AppColors.success : AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.clay.background,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: context.clay.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _detailStat(context, formattedDate,
                        loc.conversationHistoryDateLabel),
                    Container(
                      width: 1.5,
                      height: 28,
                      color: context.clay.border,
                    ),
                    _detailStat(context, '${duration}m',
                        loc.conversationHistoryDurationLabel),
                    Container(
                      width: 1.5,
                      height: 28,
                      color: context.clay.border,
                    ),
                    _detailStat(context, '$totalTurns',
                        loc.conversationHistoryTurnsLabel),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.conversationHistoryScoreBreakdownTitle,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.clay.text,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.clay.background,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: context.clay.border, width: 1.5),
                ),
                child: Column(
                  children: [
                    _scoreRow(context, loc.conversationHistoryScoreOverall,
                        totalScore, scoreColor),
                    if (grammarScore != null)
                      _scoreRow(context, loc.conversationHistoryScoreGrammar,
                          grammarScore, null),
                    if (vocabScore != null)
                      _scoreRow(context, loc.conversationHistoryScoreVocabulary,
                          vocabScore, null),
                    if (fluencyScore != null)
                      _scoreRow(context, loc.conversationHistoryScoreFluency,
                          fluencyScore, null),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: modeStyle.color.withValues(alpha: 0.08),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: modeStyle.color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  loc.conversationHistoryReplayComingSoon,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: modeStyle.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _detailStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: context.clay.text,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.clay.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _scoreRow(
      BuildContext context, String label, double score, Color? overrideColor) {
    final color = overrideColor ??
        (score >= 8
            ? AppColors.success
            : score >= 5
                ? AppColors.gold
                : AppColors.error);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: context.clay.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            score.toStringAsFixed(1),
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(iconId: AppIcons.history, size: 48),
          const SizedBox(height: 16),
          Text(
            context.loc.conversationHistoryEmptyTitle,
            style: AppTypography.bodyMd.copyWith(
              color: context.clay.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.conversationHistoryEmptyBody,
            style: AppTypography.caption.copyWith(
              color: context.clay.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final String value;
  final Color color;

  const _FilterOption({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _ModeStyle {
  final String iconUrl;
  final Color color;

  const _ModeStyle({required this.iconUrl, required this.color});

  factory _ModeStyle.from(String mode) {
    switch (mode) {
      case 'roleplay':
        return const _ModeStyle(
            iconUrl: AppIcons.scenario, color: AppColors.teal);
      case 'story':
        return const _ModeStyle(
            iconUrl: AppIcons.story, color: AppColors.purple);
      case 'tone':
        return const _ModeStyle(iconUrl: AppIcons.tone, color: AppColors.gold);
      case 'vocab':
        return const _ModeStyle(
            iconUrl: AppIcons.vocabHub, color: AppColors.coral);
      default:
        return const _ModeStyle(
            iconUrl: AppIcons.scenario, color: AppColors.teal);
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const _HistoryCard({
    required this.data,
    this.onTap,
    this.onRename,
    this.onDelete,
  });

  String _formatRelative(BuildContext context, String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final loc = context.loc;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return loc.conversationHistoryRelativeJustNow;
      if (diff.inMinutes < 60) {
        return loc.conversationHistoryRelativeMinutesAgo(diff.inMinutes);
      }
      if (diff.inHours < 24) {
        return loc.conversationHistoryRelativeHoursAgo(diff.inHours);
      }
      if (diff.inDays == 1) return loc.conversationHistoryYesterday;
      if (diff.inDays < 7) {
        return loc.conversationHistoryRelativeDaysAgo(diff.inDays);
      }
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return '—';
    }
  }

  String _lastMessagePreview() {
    final turns = data['turns'] as List<dynamic>? ?? const [];
    for (var i = turns.length - 1; i >= 0; i--) {
      final entry = turns[i];
      if (entry is! Map<String, dynamic>) continue;
      final type = entry['type'] as String? ?? '';
      final text = (entry['text'] as String? ?? '').trim();
      if (type == 'user' && text.isNotEmpty) return text;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final mode = data['mode'] as String? ?? 'roleplay';
    final modeStyle = _ModeStyle.from(mode);
    final title = (data['title'] as String? ?? '').trim();
    final topic = (data['topic'] as String? ?? '').trim();
    final difficulty = (data['difficulty'] as String? ?? '').trim();
    final status = data['status'] as String? ?? '';
    final createdAt = data['createdAt'] as String?;
    final totalScore = (data['totalScore'] as num?)?.toDouble() ?? 0.0;
    final totalTurns = (data['totalTurns'] as num?)?.toInt() ??
        ((data['turns'] as List<dynamic>?)
                ?.where((m) => m is Map<String, dynamic> && m['type'] == 'user')
                .length ??
            0);
    final duration = (data['duration'] as num?)?.toInt() ?? 0;
    final isCompleted = status == 'completed';
    final preview = _lastMessagePreview();
    final displayTitle = title.isNotEmpty
        ? title
        : (topic.isNotEmpty
            ? topic
            : context.loc.conversationHistoryFallbackTitle);

    final scoreColor = totalScore >= 8
        ? AppColors.success
        : totalScore >= 5
            ? AppColors.gold
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.clay.surface,
        border: Border.all(color: context.clay.border, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.card(context),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: ClayPressable(
          onTap: onTap,
          scaleDown: 0.98,
          builder: (context, isPressed) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: modeStyle.color.withValues(alpha: 0.12),
                            borderRadius: AppRadius.smBorder,
                          ),
                          child: AppIcon(iconId: modeStyle.iconUrl, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayTitle,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nunito',
                                  color: context.clay.text,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                topic.isNotEmpty
                                    ? topic
                                    : _modeLabel(context, mode),
                                style: AppTypography.caption.copyWith(
                                  color: modeStyle.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.12),
                              borderRadius: AppRadius.fullBorder,
                              border: Border.all(
                                color: scoreColor.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 12, color: scoreColor),
                                const SizedBox(width: 3),
                                Text(
                                  totalScore.toStringAsFixed(1),
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scoreColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        _menuButton(context),
                      ],
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        preview,
                        style: AppTypography.bodySm.copyWith(
                          color: context.clay.textMuted,
                          fontSize: 12,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pills group is wrapped in Expanded(Wrap) so that
                        // longer locale strings (e.g. "Đã hoàn thành" /
                        // "Tình huống") can break to a second line instead
                        // of pushing the meta icons off-screen. Meta icons
                        // on the right keep their natural width and stay
                        // anchored.
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _modePill(
                                  _modeLabel(context, mode), modeStyle.color),
                              _statusPill(context, isCompleted),
                              if (difficulty.isNotEmpty)
                                _softPill(difficulty, modeStyle.color),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _metaIcon(context, Icons.schedule_rounded,
                            _formatRelative(context, createdAt)),
                        const SizedBox(width: 10),
                        _metaIcon(context, Icons.timer_outlined,
                            duration > 0 ? '${duration}m' : '—'),
                        const SizedBox(width: 10),
                        _metaIcon(context, Icons.forum_outlined, '$totalTurns'),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: PopupMenuButton<String>(
        tooltip: context.loc.conversationHistoryMoreMenuTooltip,
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert_rounded,
            size: 20, color: context.clay.textMuted),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        color: context.clay.surface,
        onSelected: (value) {
          switch (value) {
            case 'rename':
              onRename?.call();
              break;
            case 'delete':
              onDelete?.call();
              break;
          }
        },
        itemBuilder: (ctx) => [
          PopupMenuItem(
            value: 'rename',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: ctx.clay.text),
                const SizedBox(width: 10),
                Text(ctx.loc.conversationHistoryRenameAction,
                    style: AppTypography.bodySm
                        .copyWith(color: ctx.clay.text)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
                const SizedBox(width: 10),
                Text(ctx.loc.conversationHistoryDeleteAction,
                    style:
                        AppTypography.bodySm.copyWith(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(BuildContext context, bool isCompleted) {
    final color = isCompleted ? AppColors.success : AppColors.gold;
    final loc = context.loc;
    final label = isCompleted
        ? loc.conversationHistoryStatusCompleted
        : loc.conversationHistoryStatusInProgress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _softPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Mode label pill — fully tinted with the mode's accent. Replaces the
  /// previous left-edge colored bar so the mode signal lives in the data
  /// row alongside Status / Difficulty rather than in chrome decoration.
  Widget _modePill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.2),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _metaIcon(BuildContext context, IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.clay.textFaint),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: context.clay.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _modeLabel(BuildContext context, String mode) {
    final loc = context.loc;
    switch (mode) {
      case 'roleplay':
        return loc.conversationHistoryFilterScenario;
      case 'story':
        return loc.conversationHistoryFilterStory;
      case 'tone':
        return loc.conversationHistoryFilterTranslator;
      case 'vocab':
        return loc.conversationHistoryModeVocab;
      default:
        return loc.conversationHistoryModeSession;
    }
  }
}

/// Clay-pill filter chip — same visual language as `_FilterChip` in
/// `my_library_screen.dart`. When selected, fills with the accent color
/// at 22% alpha + 2px accent border + colored drop shadow. Resting state
/// is the standard clayWhite surface with clayBorder.
class _ClayFilterChip extends StatelessWidget {
  final String label;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClayFilterChip({
    required this.label,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.95,
      builder: (context, isPressed) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.22)
                : context.clay.surface,
            borderRadius: AppRadius.fullBorder,
            border: Border.all(
              color: isSelected ? accentColor : context.clay.border,
              width: 2,
            ),
            boxShadow: isSelected
                ? AppShadows.colored(accentColor, alpha: 0.45)
                : AppShadows.card(context),
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: context.clay.text,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
