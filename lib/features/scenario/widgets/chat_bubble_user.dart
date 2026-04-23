import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/selectable_text_with_save.dart';
import '../../../shared/widgets/clay_pressable.dart';

class ChatBubbleUser extends StatelessWidget {
  final String text;
  final VoidCallback? onListen;
  final void Function(String selectedText, String fullContext)? onSaveSelection;

  /// Per-mode accent for the bubble fill + shadow. Defaults to Scenario's
  /// teal; Story passes purple so the bubble matches the mode theme.
  final Color accentColor;

  const ChatBubbleUser({
    super.key,
    required this.text,
    this.onListen,
    this.onSaveSelection,
    this.accentColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: SelectableTextWithSave(
                text: text,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.warmDark,
                  height: 1.5,
                  letterSpacing: 0.15,
                ),
                onSave: onSaveSelection,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClayPressable(
                  onTap: onListen,
                  scaleDown: 0.90,
                  builder: (context, isPressed) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.clayBeige,
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(iconId: AppIcons.listen, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            'Listen',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warmMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
