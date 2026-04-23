import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/constants/topic_constants.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../home/providers/home_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/story_stepper.dart';

/// Custom-story creation flow. Three steps:
/// 1. Topic — pick from the user's onboarding favorites, the wider topic
///    catalog, or type a custom topic inline.
/// 2. Character — pick a conversation partner archetype, or describe a
///    custom partner inline.
/// 3. Context — optional free-form sentence to anchor the scenario.
///
/// On step 3 the user taps "Generate Story →"; we call
/// [StoryProvider.startFromCustom] and pop `true` so the caller can navigate
/// to `/story/chat`.
///
/// Design system rule: Story mode uses purple as the accent colour. All
/// focus borders, active chips, and brand CTAs inside this screen follow
/// [AppColors.purple] / [AppColors.purpleDeep] rather than the default teal.
class StoryCustomFormScreen extends StatefulWidget {
  const StoryCustomFormScreen({super.key});

  @override
  State<StoryCustomFormScreen> createState() => _StoryCustomFormScreenState();
}

class _StoryCustomFormScreenState extends State<StoryCustomFormScreen> {
  static const _paidTiers = {'pro', 'premium'};

  int _step = 0;
  String? _topicId;
  String? _topicLabel;
  String? _character;
  final TextEditingController _contextCtrl = TextEditingController();
  final TextEditingController _customTopicCtrl = TextEditingController();
  final TextEditingController _customCharacterCtrl = TextEditingController();
  bool _isGenerating = false;

  bool _readIsPro() {
    final tier = context.read<HomeProvider>().userProfile?.tier ?? 'free';
    return _paidTiers.contains(tier);
  }

  @override
  void dispose() {
    _contextCtrl.dispose();
    _customTopicCtrl.dispose();
    _customCharacterCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _topicId != null && _topicId!.trim().isNotEmpty;
      case 1:
        if (_character == null) return false;
        if (_character == 'Custom' &&
            _customCharacterCtrl.text.trim().isEmpty) {
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _next() {
    if (!_canProceed) return;
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      _generate();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step -= 1);
    } else {
      Navigator.of(context).pop(false);
    }
  }

  void _onSelectChip(String id, String label) {
    setState(() {
      _topicId = id;
      _topicLabel = label;
      _customTopicCtrl.clear();
    });
  }

  void _onCustomTopicChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        if (_topicId != null && !_isKnownTopic(_topicId!)) {
          _topicId = null;
          _topicLabel = null;
        }
      } else {
        _topicId = trimmed;
        _topicLabel = trimmed;
      }
    });
  }

  void _onSelectCharacter(String id) {
    if (id == 'Custom' && !_readIsPro()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.warmDark,
            content: Text(
              'Custom character is a Pro feature. Upgrade to unlock.',
              style: AppTypography.bodySm.copyWith(color: AppColors.clayWhite),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      return;
    }
    setState(() => _character = id);
  }

  void _onCustomCharacterChanged(String _) {
    setState(() {});
  }

  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    final storyProvider = context.read<StoryProvider>();
    final profile = context.read<HomeProvider>().userProfile;
    final level = profile?.proficiencyLevel ?? 'intermediate';
    final customCtx = _contextCtrl.text.trim();
    final characterPref = _character == 'Custom'
        ? _customCharacterCtrl.text.trim()
        : (_character ?? 'Any');

    final ok = await storyProvider.startFromCustom(
      topic: _topicId ?? 'social',
      level: level,
      characterPreference: characterPref,
      customContext: customCtx.isEmpty ? null : customCtx,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(storyProvider.error ?? 'Could not create story. Try again.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds =
        context.watch<HomeProvider>().userProfile?.selectedTopics ?? const [];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(onClose: () => Navigator.of(context).pop(false)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: StoryStepper(currentStep: _step),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppAnimations.durationNormal,
                switchInCurve: AppAnimations.easeClay,
                child: _buildStep(favoriteIds),
              ),
            ),
            _Footer(
              step: _step,
              canProceed: _canProceed,
              isLoading: _isGenerating,
              onNext: _next,
              onBack: _back,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(List<String> favoriteIds) {
    switch (_step) {
      case 0:
        final customActive = _topicId != null && !_isKnownTopic(_topicId!);
        return _TopicStep(
          key: const ValueKey('topic'),
          favoriteIds: favoriteIds,
          selectedId: _topicId,
          customTopicCtrl: _customTopicCtrl,
          isCustomActive: customActive,
          onSelect: _onSelectChip,
          onCustomChanged: _onCustomTopicChanged,
        );
      case 1:
        final tier = context.watch<HomeProvider>().userProfile?.tier ?? 'free';
        final isPro = _paidTiers.contains(tier);
        return _CharacterStep(
          key: const ValueKey('character'),
          selected: _character,
          customCtrl: _customCharacterCtrl,
          isPro: isPro,
          onSelect: _onSelectCharacter,
          onCustomChanged: _onCustomCharacterChanged,
        );
      case 2:
        return _ContextStep(
          key: const ValueKey('context'),
          controller: _contextCtrl,
          topicLabel: _topicLabel ?? '—',
          characterLabel: _characterLabelFor(_character),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _isKnownTopic(String id) => topicOptions.any((t) => t.id == id);

  String _characterLabelFor(String? id) {
    switch (id) {
      case 'Male':
        return 'male';
      case 'Female':
        return 'female';
      case 'Young':
        return 'young';
      case 'Older':
        return 'older';
      case 'Any':
        return 'surprise';
      case 'Custom':
        return 'custom';
      default:
        return '—';
    }
  }
}

class _AppBar extends StatelessWidget {
  final VoidCallback onClose;

  const _AppBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          ClayPressable(
            onTap: onClose,
            scaleDown: 0.9,
            builder: (_, __) => const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close_rounded,
                size: 22,
                color: AppColors.warmDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Create Your Story',
              style: AppTypography.h2.copyWith(
                color: AppColors.purpleDeep,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicStep extends StatelessWidget {
  final List<String> favoriteIds;
  final String? selectedId;
  final TextEditingController customTopicCtrl;
  final bool isCustomActive;
  final void Function(String id, String label) onSelect;
  final ValueChanged<String> onCustomChanged;

  const _TopicStep({
    super.key,
    required this.favoriteIds,
    required this.selectedId,
    required this.customTopicCtrl,
    required this.isCustomActive,
    required this.onSelect,
    required this.onCustomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = topicOptions
        .where((t) => favoriteIds.contains(t.id))
        .toList(growable: false);
    final explore = topicOptions
        .where((t) => !favoriteIds.contains(t.id))
        .toList(growable: false);

    final hasFavorites = favorites.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: 'Pick a topic',
            subtitle: 'Your story will revolve around this theme.',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (hasFavorites) ...[
            _SectionLabel(
              text: 'Your favorites',
              iconId: AppIcons.sparkle,
            ),
            const SizedBox(height: 10),
            _TopicWrap(
              topics: favorites,
              selectedId: selectedId,
              onSelect: onSelect,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(
              text: 'Explore more',
              iconId: AppIcons.search,
            ),
            const SizedBox(height: 10),
          ],
          _TopicWrap(
            topics: explore,
            selectedId: selectedId,
            onSelect: onSelect,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            text: 'Or write your own',
            iconId: 'sparkle',
          ),
          const SizedBox(height: 10),
          _InlineCustomTopic(
            controller: customTopicCtrl,
            isActive: isCustomActive,
            onChanged: onCustomChanged,
          ),
        ],
      ),
    );
  }
}

class _TopicWrap extends StatelessWidget {
  final List<TopicOption> topics;
  final String? selectedId;
  final void Function(String id, String label) onSelect;

  const _TopicWrap({
    required this.topics,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.smd,
      runSpacing: AppSpacing.smd,
      children: topics
          .map((t) => _TopicChip(
                topic: t,
                isSelected: selectedId == t.id,
                onTap: () => onSelect(t.id, t.label),
              ))
          .toList(),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final TopicOption topic;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicChip({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      builder: (_, __) {
        return AnimatedContainer(
          duration: AppAnimations.durationMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smd,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? topic.color.withValues(alpha: 0.25)
                : topic.color.withValues(alpha: 0.10),
            borderRadius: AppRadius.fullBorder,
            border: Border.all(
              color: isSelected ? AppColors.warmDark : AppColors.clayBorder,
              width: 2,
            ),
            boxShadow: isSelected ? AppShadows.clayBold : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(iconId: topic.iconId, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                topic.label,
                style: AppTypography.labelMd.copyWith(
                  fontSize: 13,
                  color: AppColors.warmDark,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String iconId;

  const _SectionLabel({required this.text, required this.iconId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(iconId: iconId, size: 14),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: AppTypography.caption.copyWith(
            color: AppColors.warmMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _InlineCustomTopic extends StatefulWidget {
  final TextEditingController controller;
  final bool isActive;
  final ValueChanged<String> onChanged;

  const _InlineCustomTopic({
    required this.controller,
    required this.isActive,
    required this.onChanged,
  });

  @override
  State<_InlineCustomTopic> createState() => _InlineCustomTopicState();
}

class _InlineCustomTopicState extends State<_InlineCustomTopic> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _hasFocus || widget.isActive;
    final borderColor = highlight
        ? AppColors.purpleDeep
        : AppColors.purple.withValues(alpha: 0.35);
    final iconColor = highlight ? AppColors.purpleDeep : AppColors.warmMuted;

    return AnimatedContainer(
      duration: AppAnimations.durationFast,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: highlight
            ? AppShadows.colored(AppColors.purple, alpha: 0.22)
            : AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLength: 50,
              textInputAction: TextInputAction.done,
              onChanged: widget.onChanged,
              style: AppTypography.bodyMd.copyWith(
                fontSize: 14,
                color: AppColors.warmDark,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: AppColors.purpleDeep,
              decoration: InputDecoration(
                hintText: 'e.g. startup pitch, beach vacation',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.warmLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                fillColor: Colors.transparent,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                counterStyle: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: AppAnimations.durationFast,
            switchInCurve: AppAnimations.easeClay,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: widget.isActive
                ? Padding(
                    key: const ValueKey('added'),
                    padding: const EdgeInsets.only(right: 10, left: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.18),
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.purpleDeep,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Added',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.purpleDeep,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty'), width: 8),
          ),
        ],
      ),
    );
  }
}

class _CharacterStep extends StatelessWidget {
  final String? selected;
  final TextEditingController customCtrl;
  final bool isPro;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onCustomChanged;

  const _CharacterStep({
    super.key,
    required this.selected,
    required this.customCtrl,
    required this.isPro,
    required this.onSelect,
    required this.onCustomChanged,
  });

  static const _options = <_CharacterOption>[
    _CharacterOption(
      id: 'Any',
      label: 'Surprise me',
      description: 'The AI picks a partner that fits the topic.',
      icon: Icons.auto_awesome_rounded,
    ),
    _CharacterOption(
      id: 'Male',
      label: 'Male',
      description: 'He / him. Direct and confident tone.',
      icon: Icons.male_rounded,
    ),
    _CharacterOption(
      id: 'Female',
      label: 'Female',
      description: 'She / her. Warm and expressive tone.',
      icon: Icons.female_rounded,
    ),
    _CharacterOption(
      id: 'Young',
      label: 'Young',
      description: 'Energetic, casual, uses modern slang.',
      icon: Icons.emoji_people_rounded,
    ),
    _CharacterOption(
      id: 'Older',
      label: 'Older',
      description: 'Calm and thoughtful, more formal register.',
      icon: Icons.elderly_rounded,
    ),
    _CharacterOption(
      id: 'Custom',
      label: 'Custom',
      description: 'Describe your own partner below.',
      icon: Icons.edit_note_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isCustom = selected == 'Custom';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: 'Pick a character',
            subtitle: 'Who do you want to talk to in this story?',
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, i) {
              final opt = _options[i];
              final isCustomOption = opt.id == 'Custom';
              return _CharacterCard(
                option: opt,
                isSelected: selected == opt.id,
                isProOnly: isCustomOption,
                isLocked: isCustomOption && !isPro,
                onTap: () => onSelect(opt.id),
              );
            },
          ),
          AnimatedSize(
            duration: AppAnimations.durationNormal,
            curve: AppAnimations.easeClay,
            alignment: Alignment.topCenter,
            child: isCustom
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(
                          text: 'Describe your partner',
                          iconId: 'sparkle',
                        ),
                        const SizedBox(height: 10),
                        _CustomCharacterInput(
                          controller: customCtrl,
                          onChanged: onCustomChanged,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CharacterOption {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  const _CharacterOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}

class _CharacterCard extends StatelessWidget {
  final _CharacterOption option;
  final bool isSelected;
  final bool isProOnly;
  final bool isLocked;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.isProOnly = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentBorderColor = isProOnly
        ? (isLocked
            ? AppColors.gold.withValues(alpha: 0.55)
            : AppColors.goldDeep)
        : (isSelected ? AppColors.purpleDeep : AppColors.clayBorder);

    final iconGradient = isProOnly
        ? [AppColors.gold, AppColors.goldDeep]
        : (isSelected
            ? [AppColors.purple, AppColors.purpleDeep]
            : [
                AppColors.purple.withValues(alpha: 0.35),
                AppColors.purpleDeep.withValues(alpha: 0.35),
              ]);

    final cardShadow = isSelected
        ? AppShadows.colored(
            isProOnly ? AppColors.gold : AppColors.purple,
            alpha: 0.3,
          )
        : (isProOnly && !isLocked
            ? AppShadows.colored(AppColors.gold, alpha: 0.18)
            : AppShadows.card);

    final cardBg = isSelected
        ? (isProOnly
            ? AppColors.gold.withValues(alpha: 0.14)
            : AppColors.purple.withValues(alpha: 0.12))
        : (isProOnly
            ? AppColors.gold.withValues(alpha: 0.06)
            : AppColors.clayWhite);

    return Opacity(
      opacity: isLocked ? 0.78 : 1.0,
      child: ClayPressable(
        onTap: onTap,
        scaleDown: 0.96,
        builder: (_, __) {
          return AnimatedContainer(
            duration: AppAnimations.durationMedium,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(
                color: accentBorderColor,
                width: isSelected || isProOnly ? 2 : 1.5,
              ),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: iconGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : option.icon,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: isProOnly
                            ? AppColors.goldDeep
                            : AppColors.purpleDeep,
                        size: 20,
                      )
                    else if (isProOnly)
                      const _ProBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  option.label,
                  style: AppTypography.labelLg.copyWith(
                    color: isProOnly
                        ? AppColors.goldDark
                        : (isSelected
                            ? AppColors.purpleDeep
                            : AppColors.warmDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    option.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warmMuted,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.22),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 11,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 3),
          Text(
            'PRO',
            style: AppTypography.caption.copyWith(
              color: AppColors.goldDark,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCharacterInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CustomCharacterInput({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_CustomCharacterInput> createState() => _CustomCharacterInputState();
}

class _CustomCharacterInputState extends State<_CustomCharacterInput> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasFocus
        ? AppColors.purpleDeep
        : AppColors.purple.withValues(alpha: 0.4);

    return AnimatedContainer(
      duration: AppAnimations.durationFast,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.clayWhite,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: _hasFocus
            ? AppShadows.colored(AppColors.purple, alpha: 0.25)
            : AppShadows.card,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        minLines: 3,
        maxLines: 5,
        maxLength: 160,
        onChanged: widget.onChanged,
        style: AppTypography.bodyMd.copyWith(
          fontSize: 15,
          color: AppColors.warmDark,
          height: 1.35,
        ),
        cursorColor: AppColors.purpleDeep,
        decoration: InputDecoration(
          hintText: 'Describe personality, role, and speaking style.\n'
              'e.g. My strict but supportive professor who pushes me to '
              'explain my reasoning.',
          hintStyle: AppTypography.bodyMd.copyWith(
            color: AppColors.warmLight,
            fontSize: 14,
            height: 1.35,
          ),
          contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          counterStyle: AppTypography.caption.copyWith(
            color: AppColors.warmMuted,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _ContextStep extends StatefulWidget {
  final TextEditingController controller;
  final String topicLabel;
  final String characterLabel;

  const _ContextStep({
    super.key,
    required this.controller,
    required this.topicLabel,
    required this.characterLabel,
  });

  @override
  State<_ContextStep> createState() => _ContextStepState();
}

class _ContextStepState extends State<_ContextStep> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasFocus
        ? AppColors.purpleDeep
        : AppColors.purple.withValues(alpha: 0.4);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: 'Any extra context?',
            subtitle: 'Optional — add a twist or specific situation.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(
            topicLabel: widget.topicLabel,
            characterLabel: widget.characterLabel,
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedContainer(
            duration: AppAnimations.durationFast,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.clayWhite,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: _hasFocus
                  ? AppShadows.colored(AppColors.purple, alpha: 0.25)
                  : AppShadows.card,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              minLines: 3,
              maxLines: 5,
              maxLength: 220,
              style: AppTypography.bodyMd.copyWith(
                fontSize: 15,
                color: AppColors.warmDark,
                height: 1.35,
              ),
              cursorColor: AppColors.purpleDeep,
              decoration: InputDecoration(
                hintText:
                    "e.g. I'm meeting my partner's parents for the first time.",
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.warmLight,
                  fontSize: 14,
                  height: 1.35,
                ),
                contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                counterStyle: AppTypography.caption.copyWith(
                  color: AppColors.warmMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String topicLabel;
  final String characterLabel;

  const _SummaryCard({
    required this.topicLabel,
    required this.characterLabel,
  });

  String _composeSummary() {
    final topic = topicLabel.trim().isEmpty ? '—' : topicLabel;
    if (characterLabel == 'surprise') {
      return 'A $topic story — the AI picks your partner.';
    }
    if (characterLabel == '—') {
      return 'A $topic story.';
    }
    return 'A $topic story with a $characterLabel partner.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const AppIcon(iconId: 'sparkle', size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _composeSummary(),
              style: AppTypography.bodySm.copyWith(
                color: AppColors.warmDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodySm.copyWith(color: AppColors.warmMuted),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final int step;
  final bool canProceed;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Footer({
    required this.step,
    required this.canProceed,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          children: [
            ClayButton(
              text: isLast ? 'Generate Story \u{2192}' : 'Continue \u{2192}',
              variant: ClayButtonVariant.accentPurple,
              isLoading: isLoading,
              onTap: canProceed && !isLoading ? onNext : null,
            ),
            if (step > 0) ...[
              const SizedBox(height: 8),
              ClayButton(
                text: 'Back',
                variant: ClayButtonVariant.secondary,
                onTap: isLoading ? null : onBack,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
