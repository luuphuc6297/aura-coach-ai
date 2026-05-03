import 'package:flutter/material.dart';

import '../../../l10n/app_loc_context.dart';
import '../tabs/word_analysis_tab.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Standalone screen wrapper for Word Analysis. Reuses the existing
/// [WordAnalysisTab] body so the rework stays additive.
class WordAnalysisScreen extends StatelessWidget {
  const WordAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) => VocabHubScaffold(
        title: context.loc.vocabHubCardWordAnalysis,
        body: const WordAnalysisTab(),
      );
}
