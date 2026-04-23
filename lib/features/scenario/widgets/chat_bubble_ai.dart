import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/cloudinary_assets.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../../shared/widgets/cloud_image.dart';
import '../../../shared/widgets/selectable_text_with_save.dart';

/// AI agent message bubble. Optional listen + translate action pills appear
/// below the bubble whenever their callbacks are provided. Translation text,
/// loading state, and tints are owned by the parent so the bubble stays
/// stateless and re-renders consistently while the user scrolls.
class ChatBubbleAi extends StatelessWidget {
  final String text;
  final String senderName;
  final void Function(String selectedText, String fullContext)? onSaveSelection;

  /// Tap handler for the "Listen" pill. Pill is hidden when null.
  final VoidCallback? onListen;

  /// Tap handler for the "Translate" pill. Pill is hidden when null. The
  /// parent should toggle translation availability via [translation] /
  /// [isTranslating].
  final VoidCallback? onTranslate;

  /// Vietnamese translation to display under the English text. When null and
  /// [isTranslating] is false the bubble shows English only.
  final String? translation;

  /// True while the parent is fetching the translation. Renders a small
  /// inline progress row under the bubble.
  final bool isTranslating;

  /// Tints the sender label and the active "Translated" pill background. Lets
  /// each mode (Scenario=teal, Story=purple, ...) keep its own accent.
  final Color accentColor;

  const ChatBubbleAi({
    super.key,
    required this.text,
    this.senderName = 'Aura Coach',
    this.onSaveSelection,
    this.onListen,
    this.onTranslate,
    this.translation,
    this.isTranslating = false,
    this.accentColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    final showActions = onListen != null || onTranslate != null;
    final hasTranslation = translation != null && translation!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.clayBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: ClipOval(
            child: CloudImage(url: CloudinaryAssets.chatbot, size: 32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.clayWhite,
                  border: Border.all(color: AppColors.clayBorder, width: 1.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableTextWithSave(
                      text: text,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.warmDark,
                        height: 1.5,
                        letterSpacing: 0.15,
                      ),
                      onSave: onSaveSelection,
                    ),
                    if (hasTranslation) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: AppColors.clayBorder.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translation!,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.warmMuted,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showActions || isTranslating) ...[
                const SizedBox(height: 6),
                _ActionRow(
                  onListen: onListen,
                  onTranslate: onTranslate,
                  isTranslating: isTranslating,
                  hasTranslation: hasTranslation,
                  accentColor: accentColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback? onListen;
  final VoidCallback? onTranslate;
  final bool isTranslating;
  final bool hasTranslation;
  final Color accentColor;

  const _ActionRow({
    required this.onListen,
    required this.onTranslate,
    required this.isTranslating,
    required this.hasTranslation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (onListen != null)
          _ActionPill(
            icon: const AppIcon(iconId: AppIcons.listen, size: 12),
            label: 'Listen',
            onTap: onListen,
          ),
        if (onTranslate != null)
          _ActionPill(
            icon: isTranslating
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  )
                : Icon(
                    Icons.translate_rounded,
                    size: 12,
                    color: hasTranslation ? accentColor : AppColors.warmMuted,
                  ),
            label: hasTranslation ? 'Translated' : 'Translate',
            onTap: isTranslating ? null : onTranslate,
            tinted: hasTranslation,
            accentColor: accentColor,
          ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final bool tinted;
  final Color accentColor;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tinted = false,
    this.accentColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        tinted ? accentColor.withValues(alpha: 0.16) : AppColors.clayBeige;
    final fg = tinted ? accentColor : AppColors.warmMuted;
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.9,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.fullBorder,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
