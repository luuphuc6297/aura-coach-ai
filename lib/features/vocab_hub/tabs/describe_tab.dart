import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/gemini/types.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_button.dart';
import '../../../shared/widgets/clay_card.dart';
import '../../../shared/widgets/clay_text_input.dart';
import '../providers/describe_word_provider.dart';

/// Describe-a-Word tab. User enters a Vietnamese description of the word
/// they're trying to recall; the LLM returns 3-5 ranked English candidates
/// rendered as confidence-scored cards.
class DescribeTab extends StatefulWidget {
  const DescribeTab({super.key});

  @override
  State<DescribeTab> createState() => _DescribeTabState();
}

class _DescribeTabState extends State<DescribeTab> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLookup(DescribeWordProvider provider) {
    FocusScope.of(context).unfocus();
    provider.lookup(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DescribeWordProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Describe the word in Vietnamese',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          ClayTextInput(
            controller: _controller,
            hintText: context.loc.vocabDescribeHint,
            accentColor: AppColors.coral,
            textStyle: AppTypography.bodyMd,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _onLookup(provider),
          ),
          const SizedBox(height: AppSpacing.md),
          ClayButton(
            text: provider.loading ? 'Searching…' : 'Find word',
            variant: ClayButtonVariant.accentCoral,
            isLoading: provider.loading,
            onTap: provider.loading ? null : () => _onLookup(provider),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (provider.error != null)
            Text(
              provider.error!,
              style: AppTypography.bodySm.copyWith(color: AppColors.coral),
            ),
          if (provider.result != null) ...[
            if (provider.result!.candidates.isEmpty)
              Text(
                'No matches found. Try rephrasing your description.',
                style:
                    AppTypography.bodySm.copyWith(color: context.clay.textMuted),
              )
            else
              ...provider.result!.candidates
                  .map((c) => _CandidateTile(candidate: c)),
          ],
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final EnCandidate candidate;
  const _CandidateTile({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final confidencePct = (candidate.confidence.clamp(0.0, 1.0) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClayCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(candidate.en, style: AppTypography.h3),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ConfidenceBadge(pct: confidencePct),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              candidate.vn,
              style:
                  AppTypography.bodyMd.copyWith(color: context.clay.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(candidate.definition, style: AppTypography.bodySm),
            if (candidate.example.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '“${candidate.example}”',
                style: AppTypography.caption.copyWith(
                  color: context.clay.textFaint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final int pct;
  const _ConfidenceBadge({required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = pct >= 80
        ? AppColors.teal
        : pct >= 50
            ? AppColors.gold
            : AppColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$pct%',
        style: AppTypography.labelSm.copyWith(color: color),
      ),
    );
  }
}
