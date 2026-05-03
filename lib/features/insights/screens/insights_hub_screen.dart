import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/clay_palette.dart';
import '../../../l10n/app_loc_context.dart';
import '../../../shared/widgets/clay_pressable.dart';
import '../../my_library/screens/my_library_screen.dart';
import 'insights_screen.dart';

/// Insight tab wrapper that fronts both the saved-vocabulary library and the
/// analytics dashboard behind a Clay-style segmented control. With the
/// BottomNav reorder (N1) the standalone Library tab is dropped — its
/// content lives here under the "Library" sub-tab — and the Stats sub-tab
/// hosts the analytics widgets that used to be the whole Insight tab.
class InsightsHubScreen extends StatefulWidget {
  /// Sub-tab to open with. Defaults to Library because most navigations
  /// from "View saved" / mode chat surfaces want the vocab list first.
  final InsightsHubTab initialTab;

  const InsightsHubScreen({super.key, this.initialTab = InsightsHubTab.library});

  @override
  State<InsightsHubScreen> createState() => _InsightsHubScreenState();
}

enum InsightsHubTab { library, stats }

class _InsightsHubScreenState extends State<InsightsHubScreen> {
  late InsightsHubTab _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.clay.background,
      appBar: AppBar(
        backgroundColor: context.clay.background,
        surfaceTintColor: context.clay.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(context.loc.insightsTitle, style: AppTypography.h2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: _SegmentedControl(
              selected: _selected,
              onSelect: (tab) => setState(() => _selected = tab),
            ),
          ),
          Expanded(
            // IndexedStack keeps both sub-tabs alive so filter state, scroll
            // position, and any in-flight fetches survive a tab swap.
            child: IndexedStack(
              index: _selected == InsightsHubTab.library ? 0 : 1,
              children: const [
                MyLibraryScreen(embedded: true, showHeader: false),
                InsightsScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped Clay segmented control matching the Story Mode entry mockup.
/// Two slots only (Library / Stats) so we use a 50/50 split rather than a
/// dynamic Expanded loop.
class _SegmentedControl extends StatelessWidget {
  final InsightsHubTab selected;
  final ValueChanged<InsightsHubTab> onSelect;

  const _SegmentedControl({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.clay.surfaceAlt,
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: context.clay.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTab(
              label: context.loc.insightsTabLibrary,
              icon: Icons.menu_book_rounded,
              isActive: selected == InsightsHubTab.library,
              onTap: () => onSelect(InsightsHubTab.library),
            ),
          ),
          Expanded(
            child: _SegmentTab(
              label: context.loc.insightsTabStats,
              icon: Icons.insights_rounded,
              isActive: selected == InsightsHubTab.stats,
              onTap: () => onSelect(InsightsHubTab.stats),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      scaleDown: 0.96,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? context.clay.surface : Colors.transparent,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isActive ? context.clay.text : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isActive ? AppShadows.card(context) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? context.clay.text : context.clay.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? context.clay.text : context.clay.textMuted,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
