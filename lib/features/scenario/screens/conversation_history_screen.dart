import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
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
  static const _filters = [
    _FilterOption(label: 'All', value: 'all', color: AppColors.teal),
    _FilterOption(label: 'Scenario', value: 'roleplay', color: AppColors.teal),
    _FilterOption(label: 'Story', value: 'story', color: AppColors.purple),
    _FilterOption(label: 'Translator', value: 'tone', color: AppColors.gold),
  ];

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
                  const ClayBackButton(),
                  const SizedBox(width: 4),
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
            _buildFilterChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border(
          bottom: BorderSide(color: AppColors.clayBorder, width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter.value;
            return _UnderlineFilterTab(
              label: filter.label,
              accentColor: filter.color,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedFilter = filter.value),
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
        backgroundColor: AppColors.clayWhite,
        title: Text('Rename conversation', style: AppTypography.title),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.input,
          cursorColor: AppColors.teal,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: 'Conversation title',
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: AppColors.clayBorder, width: 2),
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
            child: Text('Cancel', style: TextStyle(color: AppColors.warmMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Save', style: TextStyle(color: AppColors.teal)),
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
        const SnackBar(content: Text('Rename failed. Please try again.')),
      );
    }
  }

  Future<void> _deleteConversation(Map<String, dynamic> item) async {
    final conversationId = item['id'] as String?;
    if (conversationId == null) return;
    final confirm = await showClayDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clayWhite,
        title: Text('Delete conversation?', style: AppTypography.title),
        content: Text(
          'This conversation will be permanently removed from your history.',
          style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.warmMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
        const SnackBar(content: Text('Delete failed. Please try again.')),
      );
    }
  }

  void _showConversationDetail(
      BuildContext context, Map<String, dynamic> item) {
    final mode = item['mode'] as String? ?? 'roleplay';
    final modeStyle = _ModeStyle.from(mode);
    final title = item['title'] as String? ?? '';
    final topic = item['topic'] as String? ?? 'Unknown';
    final difficulty = item['difficulty'] as String? ?? '';
    final status = item['status'] as String? ?? '';
    final createdAt = item['createdAt'] as String?;
    final totalScore = (item['totalScore'] as num?)?.toDouble() ?? 0.0;
    final grammarScore = (item['grammarScore'] as num?)?.toDouble();
    final vocabScore = (item['vocabScore'] as num?)?.toDouble();
    final fluencyScore = (item['fluencyScore'] as num?)?.toDouble();
    final totalTurns = (item['totalTurns'] as num?)?.toInt() ?? 0;
    final duration = (item['duration'] as num?)?.toInt() ?? 0;

    String formattedDate = 'Unknown';
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
          color: AppColors.clayWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          border: Border.all(color: AppColors.clayBorder, width: 2),
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
                    color: AppColors.clayBorder,
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
                            color: AppColors.warmMuted,
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
                    isCompleted ? 'Completed' : 'In Progress',
                    isCompleted ? AppColors.success : AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: AppColors.clayBorder, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _detailStat(formattedDate, 'Date'),
                    Container(
                      width: 1.5,
                      height: 28,
                      color: AppColors.clayBorder,
                    ),
                    _detailStat('${duration}m', 'Duration'),
                    Container(
                      width: 1.5,
                      height: 28,
                      color: AppColors.clayBorder,
                    ),
                    _detailStat('$totalTurns', 'Turns'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score Breakdown',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: AppColors.clayBorder, width: 1.5),
                ),
                child: Column(
                  children: [
                    _scoreRow('Overall', totalScore, scoreColor),
                    if (grammarScore != null)
                      _scoreRow('Grammar', grammarScore, null),
                    if (vocabScore != null)
                      _scoreRow('Vocabulary', vocabScore, null),
                    if (fluencyScore != null)
                      _scoreRow('Fluency', fluencyScore, null),
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
                  'Tap to replay coming soon',
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

  Widget _detailStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.warmDark,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.warmMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _scoreRow(String label, double score, Color? overrideColor) {
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
                color: AppColors.warmMuted,
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

  String _formatRelative(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
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
    final displayTitle =
        title.isNotEmpty ? title : (topic.isNotEmpty ? topic : 'Roleplay');

    final scoreColor = totalScore >= 8
        ? AppColors.success
        : totalScore >= 5
            ? AppColors.gold
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        border: Border.all(color: AppColors.clayBorder, width: 2),
        borderRadius: AppRadius.lgBorder,
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: modeStyle.color, width: 4),
            ),
          ),
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
                                  color: AppColors.warmDark,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                topic.isNotEmpty ? topic : _modeLabel(mode),
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
                          color: AppColors.warmMuted,
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
                      children: [
                        _statusPill(isCompleted),
                        const SizedBox(width: 6),
                        if (difficulty.isNotEmpty)
                          _softPill(difficulty, modeStyle.color),
                        const Spacer(),
                        _metaIcon(
                            Icons.schedule_rounded, _formatRelative(createdAt)),
                        const SizedBox(width: 10),
                        _metaIcon(Icons.timer_outlined,
                            duration > 0 ? '${duration}m' : '—'),
                        const SizedBox(width: 10),
                        _metaIcon(Icons.forum_outlined, '$totalTurns'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: PopupMenuButton<String>(
        tooltip: 'More',
        padding: EdgeInsets.zero,
        icon:
            Icon(Icons.more_vert_rounded, size: 20, color: AppColors.warmMuted),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        color: AppColors.clayWhite,
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
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'rename',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: AppColors.warmDark),
                const SizedBox(width: 10),
                Text('Rename',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.warmDark)),
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
                Text('Delete',
                    style:
                        AppTypography.bodySm.copyWith(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(bool isCompleted) {
    final color = isCompleted ? AppColors.success : AppColors.gold;
    final label = isCompleted ? 'Completed' : 'In Progress';
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

  Widget _metaIcon(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.warmLight),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: AppColors.warmMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'roleplay':
        return 'Scenario';
      case 'story':
        return 'Story';
      case 'tone':
        return 'Translator';
      case 'vocab':
        return 'Vocab';
      default:
        return 'Session';
    }
  }
}

class _UnderlineFilterTab extends StatelessWidget {
  final String label;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnderlineFilterTab({
    required this.label,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.97,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? accentColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: isSelected ? accentColor : AppColors.warmMuted,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }
}
