import 'package:flutter/material.dart';

import '../../../l10n/app_loc_context.dart';
import '../tabs/flashcards_tab.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Standalone Flashcards screen. Hosts the SM-2 review queue under the
/// shared Vocab Hub chrome.
class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) => VocabHubScaffold(
        title: context.loc.vocabFlashcardsTitle,
        body: const FlashcardsTab(),
      );
}
