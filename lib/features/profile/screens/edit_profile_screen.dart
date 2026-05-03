import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/cloudinary_assets.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_back_button.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/selection_check_circle.dart';
import '../../home/providers/home_provider.dart';

/// Edit Profile — lets the user change name, avatar, proficiency level, and
/// daily goal. The screen mirrors the onboarding visual language (same avatar
/// picker, same level cards, same daily-time pills) so the experience is
/// familiar and the form values match what was originally captured.
///
/// Local edits stay in widget state until the user taps Save; this avoids
/// accidental writes if the user backs out, and lets us compute a "dirty"
/// flag to disable the CTA when nothing has changed.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late String _avatarId;
  late String _avatarUrl;
  late String _proficiencyLevelId;
  late int _dailyMinutes;

  // Snapshot of the original values so we can compute dirty + roll back.
  String _initialName = '';
  String _initialAvatarId = '';
  String _initialLevelId = '';
  int _initialDailyMinutes = 0;

  bool _initialized = false;
  bool _isSaving = false;
  // Lets PopScope allow the final navigator pop after the user has already
  // confirmed they want to discard their unsaved edits. Without this, the
  // post-confirm pop() would re-trigger PopScope and prompt again.
  bool _allowPopOverride = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Pulls the current profile out of HomeProvider and seeds form state.
  /// Done in didChangeDependencies (not initState) so context.read works.
  void _hydrateFromProfile() {
    if (_initialized) return;
    final profile = context.read<HomeProvider>().userProfile;
    if (profile == null) return;
    _nameController.text = profile.name;
    _avatarId = profile.avatarId;
    _avatarUrl = profile.avatarUrl.isNotEmpty
        ? profile.avatarUrl
        : _avatarUrlForId(profile.avatarId);
    _proficiencyLevelId = profile.proficiencyLevel;
    _dailyMinutes = profile.dailyMinutes;
    _initialName = profile.name;
    _initialAvatarId = profile.avatarId;
    _initialLevelId = profile.proficiencyLevel;
    _initialDailyMinutes = profile.dailyMinutes;
    _initialized = true;
  }

  String _avatarUrlForId(String id) {
    return avatarOptions
        .firstWhere(
          (a) => a.id == id,
          orElse: () => avatarOptions.first,
        )
        .url;
  }

  bool get _isDirty {
    if (!_initialized) return false;
    return _nameController.text.trim() != _initialName.trim() ||
        _avatarId != _initialAvatarId ||
        _proficiencyLevelId != _initialLevelId ||
        _dailyMinutes != _initialDailyMinutes;
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  Future<bool> _confirmDiscardIfDirty() async {
    if (!_isDirty) return true;
    final loc = context.loc;
    final keep = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.editProfileDiscardTitle),
        content: Text(loc.editProfileDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.editProfileDiscardKeepEditing),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.editProfileDiscardConfirm),
          ),
        ],
      ),
    );
    return keep == true;
  }

  Future<void> _save() async {
    if (!_isValid || !_isDirty || _isSaving) return;
    final homeProvider = context.read<HomeProvider>();
    final profile = homeProvider.userProfile;
    if (profile == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSaving = true);
    try {
      final updated = profile.copyWith(
        name: _nameController.text.trim(),
        avatarId: _avatarId,
        avatarUrl: _avatarUrl,
        proficiencyLevel: _proficiencyLevelId,
        dailyMinutes: _dailyMinutes,
      );
      await homeProvider.updateProfile(updated);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.loc.editProfileSaveSuccess)),
      );
      // Bypass the dirty-check dialog — the user's edits were just persisted.
      setState(() => _allowPopOverride = true);
      router.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.loc.editProfileSaveFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _hydrateFromProfile();
    final profile = context.watch<HomeProvider>().userProfile;

    if (profile == null) {
      return Scaffold(
        backgroundColor: context.clay.background,
        appBar: _appBar(context),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.teal,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return PopScope(
      canPop: _allowPopOverride || !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmDiscardIfDirty();
        if (!ok || !mounted) return;
        setState(() => _allowPopOverride = true);
        // Re-issue the pop now that PopScope will let it through.
        GoRouter.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: context.clay.background,
        appBar: _appBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AvatarPreview(url: _avatarUrl),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(context.loc.editProfileSectionBuddy),
              const SizedBox(height: AppSpacing.md),
              _AvatarPicker(
                selectedId: _avatarId,
                onSelect: (avatar) => setState(() {
                  _avatarId = avatar.id;
                  _avatarUrl = avatar.url;
                }),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(context.loc.editProfileSectionName),
              const SizedBox(height: AppSpacing.md),
              _NameField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(context.loc.editProfileSectionLevel),
              const SizedBox(height: AppSpacing.md),
              ...ProficiencyLevel.values.map((level) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LevelCard(
                    level: level,
                    isSelected: _proficiencyLevelId == level.id,
                    onTap: () =>
                        setState(() => _proficiencyLevelId = level.id),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(context.loc.editProfileSectionDailyGoal),
              const SizedBox(height: AppSpacing.md),
              _DailyTimeRow(
                selectedMinutes: _dailyMinutes,
                onSelect: (m) => setState(() => _dailyMinutes = m),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ClayButton(
                text: context.loc.editProfileSaveButton,
                variant: ClayButtonVariant.primary,
                isLoading: _isSaving,
                onTap: (_isDirty && _isValid && !_isSaving) ? _save : null,
              ),
              if (!_isValid) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.loc.editProfileNameRequired,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(color: AppColors.coral),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.clay.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // No custom onTap — the default ClayBackButton.pop() routes through
      // the surrounding PopScope, which handles the dirty-check dialog
      // uniformly for both system back gestures and the in-screen button.
      leading: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: ClayBackButton(),
      ),
      title: Text(context.loc.editProfileTitle, style: AppTypography.sectionTitle),
      centerTitle: true,
    );
  }
}

// ---------- subcomponents ----------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: context.clay.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final String url;
  const _AvatarPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.clay.surface,
          border: Border.all(color: AppColors.teal, width: 3),
          boxShadow: AppShadows.clay(context),
        ),
        child: ClipOval(
          child: url.isEmpty
              ? Icon(
                  Icons.person_rounded,
                  size: 56,
                  color: context.clay.textMuted,
                )
              : CloudImage(url: url, size: 106),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String selectedId;
  final ValueChanged<AvatarOption> onSelect;

  const _AvatarPicker({
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: avatarOptions.map((avatar) {
        final isSelected = selectedId == avatar.id;
        return ClayPressable(
          onTap: () => onSelect(avatar),
          scaleDown: 0.92,
          builder: (context, _) {
            return AnimatedContainer(
              duration: AppAnimations.durationMedium,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.teal : context.clay.border,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.25),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                        ...AppShadows.clay(context),
                      ]
                    : AppShadows.card(context),
              ),
              child: ClipOval(
                child: CloudImage(url: avatar.url, size: 56),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NameField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClayTextInput(
      controller: controller,
      onChanged: onChanged,
      hintText: context.loc.onboardingNameHint,
      prefixIcon: Icons.person_outline,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
    );
  }
}

class _LevelCard extends StatelessWidget {
  final ProficiencyLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  String _iconUrl() {
    switch (level) {
      case ProficiencyLevel.beginner:
        return CloudinaryAssets.levelBeginner;
      case ProficiencyLevel.intermediate:
        return CloudinaryAssets.levelIntermediate;
      case ProficiencyLevel.advanced:
        return CloudinaryAssets.levelAdvanced;
    }
  }

  Color _cefrColor() {
    switch (level) {
      case ProficiencyLevel.beginner:
        return AppColors.success;
      case ProficiencyLevel.intermediate:
        return AppColors.gold;
      case ProficiencyLevel.advanced:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      isSelected: isSelected,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          CloudImage(url: _iconUrl(), size: 56),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(level.label, style: AppTypography.title),
                    const SizedBox(width: AppSpacing.sm),
                    _CefrPill(text: level.cefr, color: _cefrColor()),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  level.description,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    color: context.clay.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SelectionCheckCircle(isSelected: isSelected),
        ],
      ),
    );
  }
}

class _CefrPill extends StatelessWidget {
  final String text;
  final Color color;
  const _CefrPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _DailyTimeRow extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelect;

  const _DailyTimeRow({
    required this.selectedMinutes,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: dailyTimeOptions.map((opt) {
        final isSelected = selectedMinutes == opt.minutes;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _DailyTimeChip(
              minutes: opt.minutes,
              isSelected: isSelected,
              onTap: () => onSelect(opt.minutes),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DailyTimeChip extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _DailyTimeChip({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      builder: (context, _) {
        return AnimatedContainer(
          duration: AppAnimations.durationFast,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.teal : context.clay.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isSelected ? context.clay.text : context.clay.border,
              width: 2,
            ),
            boxShadow: isSelected ? AppShadows.clay(context) : AppShadows.card(context),
          ),
          child: Column(
            children: [
              Text(
                '$minutes',
                style: AppTypography.title.copyWith(
                  color: context.clay.text,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'min',
                style: AppTypography.caption.copyWith(
                  color: isSelected ? context.clay.text : context.clay.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
