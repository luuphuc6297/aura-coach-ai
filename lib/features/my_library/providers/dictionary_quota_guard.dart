import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/quota_constants.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../home/providers/home_provider.dart';

/// Returns true if the user may save another dictionary item right now.
/// When the free-tier cap is reached, surfaces a SnackBar with an Upgrade CTA
/// and returns false. Unknown profile state is treated as allowed so a
/// transient load doesn't block the save flow.
Future<bool> ensureDictionaryQuota(BuildContext context) async {
  final home = context.read<HomeProvider>();
  final firebase = context.read<FirebaseDatasource>();
  final profile = home.userProfile;
  if (profile == null) return true;

  final limit = QuotaConstants.getLimit(profile.tier, 'dictionary');
  if (limit < 0) return true;

  final dateKey = _todayKey();
  final usage = await firebase.getDailyUsage(profile.uid, dateKey);
  final used = usage['dictionaryCount'] ?? 0;
  if (used >= limit) {
    if (context.mounted) _showUpgradeSnack(context, limit);
    return false;
  }
  return true;
}

/// Records a successful dictionary save against today's usage counter.
/// Caller must ensure [ensureDictionaryQuota] returned true first. Pro/premium
/// tiers still increment — useful for analytics and future tier re-tuning.
Future<void> recordDictionaryUsage(BuildContext context) async {
  final home = context.read<HomeProvider>();
  final firebase = context.read<FirebaseDatasource>();
  final profile = home.userProfile;
  if (profile == null) return;
  await firebase.incrementDailyUsage(profile.uid, _todayKey(), 'dictionary');
}

String _todayKey() => DateTime.now().toIso8601String().substring(0, 10);

void _showUpgradeSnack(BuildContext context, int limit) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Bạn đã dùng hết $limit lượt lưu từ điển hôm nay'),
      action: SnackBarAction(
        label: 'Upgrade',
        onPressed: () => context.push('/subscription'),
      ),
    ),
  );
}
