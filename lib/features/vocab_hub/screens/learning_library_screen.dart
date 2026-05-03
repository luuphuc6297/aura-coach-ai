import 'package:flutter/material.dart';

import '../../../l10n/app_loc_context.dart';
import '../../my_library/screens/my_library_screen.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Vocab Hub's Learning Library sub-screen. Reuses [MyLibraryBody] so saved
/// items stay unified with the shared /my-library experience.
class LearningLibraryScreen extends StatelessWidget {
  const LearningLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => VocabHubScaffold(
        title: context.loc.vocabLearningLibraryTitle,
        body: const MyLibraryBody(),
      );
}
