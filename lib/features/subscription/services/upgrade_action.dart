import 'package:flutter/widgets.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../providers/subscription_provider.dart';
import 'revenuecat_ui.dart';

/// Single entry-point any feature can call to trigger the upgrade flow.
/// Encapsulates the "present paywall, observe outcome, return whether
/// the user is now Pro" sequence so call sites don't need to import
/// RevenueCat UI directly.
///
/// Returns:
/// - `true` if the user is Pro after the flow (already-Pro short-circuit
///   counts), so the caller can immediately retry the gated action.
/// - `false` if the user dismissed without purchasing or restore failed.
class UpgradeAction {
  const UpgradeAction._();

  /// Trigger the upgrade modal. Use this from quota walls, Pro-locked
  /// feature cards, and any "Upgrade" CTA. Short-circuits to `true`
  /// when the user is already Pro so callers don't need to peek the
  /// provider beforehand.
  static Future<bool> run(BuildContext context) async {
    final result = await RevenueCatUiBridge.presentPaywallIfNeeded(
      requiredEntitlementIdentifier: SubscriptionProvider.proEntitlementId,
    );
    switch (result) {
      case PaywallResult.purchased:
      case PaywallResult.restored:
      case PaywallResult.notPresented:
        // notPresented = user already had the entitlement, no UI shown.
        return true;
      case PaywallResult.cancelled:
      case PaywallResult.error:
        return false;
    }
  }
}
