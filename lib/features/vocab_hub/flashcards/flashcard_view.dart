import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/my_library/models/saved_item.dart';
import '../../../shared/widgets/clay_card.dart';

/// Tap-to-flip flashcard. Front shows the headword and pronunciation; back
/// reveals the explanation and the first saved example. Resets to the front
/// whenever the underlying item changes so the next card starts closed.
class FlashcardView extends StatefulWidget {
  final SavedItem item;
  const FlashcardView({super.key, required this.item});

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  bool _revealed = false;

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      setState(() => _revealed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final pronunciation = item.pronunciation;
    final firstExample =
        (item.examples != null && item.examples!.isNotEmpty) ? item.examples!.first : null;

    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: ClayCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.correction,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            if (pronunciation != null && pronunciation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pronunciation,
                style: AppTypography.bodyMd
                    .copyWith(color: context.clay.textFaint),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (!_revealed)
              Text(
                'Tap to reveal meaning',
                style: AppTypography.bodySm
                    .copyWith(color: context.clay.textFaint),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if ((item.explanation ?? '').isNotEmpty)
                    Text(
                      item.explanation!,
                      style: AppTypography.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                  if (firstExample != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    if ((firstExample['en'] ?? '').isNotEmpty)
                      Text(
                        '“${firstExample['en']}”',
                        style: AppTypography.bodySm,
                        textAlign: TextAlign.center,
                      ),
                    if ((firstExample['vn'] ?? '').isNotEmpty)
                      Text(
                        firstExample['vn']!,
                        style: AppTypography.caption,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
