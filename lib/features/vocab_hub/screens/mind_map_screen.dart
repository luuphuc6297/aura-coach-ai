import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/prompts/prompt_constants.dart';
import '../../../features/home/providers/home_provider.dart';
import '../../../l10n/app_loc_context.dart';
import '../providers/mind_map_provider.dart';
import '../tabs/mind_map_tab.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Standalone Mind Map screen (Pro-gated). Wraps [MindMapTab] which handles
/// the Pro paywall + the canvas itself. When the route includes a `seed`
/// query parameter (e.g. `/vocab-hub/mind-map?seed=resilience`) the screen
/// auto-kicks off `generateFor` rooted at that word — used by My Library and
/// the Word Analysis footer to drop the learner straight into a freshly
/// seeded map.
class MindMapScreen extends StatefulWidget {
  final String? seedWord;

  const MindMapScreen({super.key, this.seedWord});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  bool _seedAttempted = false;

  @override
  void initState() {
    super.initState();
    if (widget.seedWord != null && widget.seedWord!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSeed());
    }
  }

  /// Fires once after the first frame. Behaviour:
  /// - No map in memory                   → generate from seed.
  /// - Map exists for the SAME seed word  → keep it (revisit).
  /// - Map exists for a DIFFERENT topic   → clear + regenerate so the user
  ///   actually sees the word they tapped from My Library / Word Analysis.
  Future<void> _maybeSeed() async {
    if (_seedAttempted || !mounted) return;
    _seedAttempted = true;
    final seed = widget.seedWord?.trim();
    if (seed == null || seed.isEmpty) return;
    final provider = context.read<MindMapProvider>();
    final profile = context.read<HomeProvider>().userProfile;
    if (profile == null) return;

    final currentTopic = provider.topic?.trim().toLowerCase();
    final seedLower = seed.toLowerCase();
    if (provider.root != null && currentTopic == seedLower) {
      return; // already showing this exact map, leave it alone
    }
    if (provider.root != null) {
      provider.clear(); // stale map from a different topic — start fresh
    }
    provider.configure(
      uid: profile.uid,
      level: CefrLevel.fromProficiencyId(profile.proficiencyLevel),
    );
    await provider.generateFor(seed, fromLibrary: true);
    if (kDebugMode) {
      debugPrint('MindMapScreen: seeded from word "$seed"');
    }
  }

  @override
  Widget build(BuildContext context) => VocabHubScaffold(
        title: context.loc.vocabMindMapTitle,
        body: const MindMapTab(),
      );
}
