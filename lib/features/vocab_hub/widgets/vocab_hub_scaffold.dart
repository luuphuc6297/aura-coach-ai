import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../shared/widgets/clay_back_button.dart';

/// Shared Scaffold wrapper for every Vocab Hub sub-screen. Centralizes the
/// cream background, the coral back button chrome, and the consistent title
/// typography so sub-screens can focus on their own body widgets.
class VocabHubScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const VocabHubScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: ClayBackButton(),
        ),
        title: Text(title, style: AppTypography.h2),
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
