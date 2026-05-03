import 'package:flutter/material.dart';

import '../../../l10n/app_loc_context.dart';
import '../tabs/describe_tab.dart';
import '../widgets/vocab_hub_scaffold.dart';

/// Standalone screen for Describe Word (VN → EN reverse dictionary). Hosts
/// the existing [DescribeTab] body under the shared Vocab Hub chrome.
class DescribeWordScreen extends StatelessWidget {
  const DescribeWordScreen({super.key});

  @override
  Widget build(BuildContext context) => VocabHubScaffold(
        title: context.loc.vocabDescribeTitle,
        body: const DescribeTab(),
      );
}
