import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/clay_palette.dart';
import '../../features/shared/providers/storage_quota_provider.dart';
import '../../l10n/app_loc_context.dart';
import 'clay_pressable.dart';

/// Displayed on the Home screen whenever storage is in `warning` or `cap`
/// state. Shows a per-mode breakdown plus the aggregate count and offers
/// two CTAs: Manage (opens Conversation History) and Upgrade (paywall).
class StorageQuotaBanner extends StatelessWidget {
  final StorageQuotaSnapshot snapshot;
  final VoidCallback onManage;
  final VoidCallback onUpgrade;

  const StorageQuotaBanner({
    super.key,
    required this.snapshot,
    required this.onManage,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.state == StorageQuotaState.healthy) {
      return const SizedBox.shrink();
    }
    final isCap = snapshot.state == StorageQuotaState.cap;
    final accent = isCap ? AppColors.error : AppColors.gold;
    final loc = context.loc;
    final breakdown = _breakdown(context, snapshot.perMode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.3),
          boxShadow: AppShadows.clay(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCap ? Icons.block_rounded : Icons.storage_rounded,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isCap
                        ? loc.storageQuotaCapTitle
                        : loc.storageQuotaWarningTitle,
                    style: AppTypography.labelMd.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (breakdown.isNotEmpty)
              Text(
                breakdown,
                style: AppTypography.caption.copyWith(
                  color: context.clay.textMuted,
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              loc.storageQuotaUsage(snapshot.total, snapshot.cap),
              style: AppTypography.caption.copyWith(
                color: context.clay.text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClayPressable(
                    onTap: onManage,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: context.clay.surfaceAlt,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                          color: context.clay.border,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        loc.storageQuotaManage,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: context.clay.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClayPressable(
                    onTap: onUpgrade,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: Text(
                        loc.storageQuotaUpgrade,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _breakdown(BuildContext context, Map<String, int> perMode) {
    if (perMode.isEmpty) return '';
    final loc = context.loc;
    final labels = <String, String>{
      'roleplay': loc.storageQuotaModeScenario,
      'story': loc.storageQuotaModeStory,
    };
    final parts = <String>[];
    for (final entry in perMode.entries) {
      if (entry.value == 0) continue;
      final label = labels[entry.key] ?? _capitalise(entry.key);
      parts.add('$label ${entry.value}');
    }
    if (parts.isEmpty) return '';
    return parts.join(' · ');
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
