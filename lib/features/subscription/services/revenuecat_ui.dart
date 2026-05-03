import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../providers/subscription_provider.dart';

/// Thin wrapper around RevenueCat's prebuilt UI flows so the rest of
/// the app never needs to import `purchases_ui_flutter` directly. Keeps
/// the paywall + customer center swappable if we later move to a fully
/// custom UI without touching every call site.
abstract final class RevenueCatUiBridge {
  /// Present the RevenueCat-hosted paywall as a full-screen modal.
  ///
  /// Pass an [offering] when you want a specific paywall (e.g. an A/B
  /// experiment offering); leave null to use the dashboard's "current"
  /// offering. Returns the [PaywallResult] so callers can react to
  /// purchase / restore / cancel outcomes.
  static Future<PaywallResult> presentPaywall({
    Offering? offering,
    bool displayCloseButton = true,
  }) {
    return RevenueCatUI.presentPaywall(
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  /// Present the paywall ONLY when the user does not already have the
  /// requested entitlement — saves a `getCustomerInfo` round-trip when
  /// the user is already Pro. Convenient for "Upgrade" CTAs that
  /// shouldn't fire if the user is already entitled.
  static Future<PaywallResult> presentPaywallIfNeeded({
    String requiredEntitlementIdentifier =
        SubscriptionProvider.proEntitlementId,
    Offering? offering,
    bool displayCloseButton = true,
  }) {
    return RevenueCatUI.presentPaywallIfNeeded(
      requiredEntitlementIdentifier,
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  /// Present RevenueCat's hosted Customer Center — handles manage
  /// subscription, restore purchases, refund requests, billing issues,
  /// and platform-store deep-links in one screen. Apple + Google both
  /// require an in-app surface that links to manage subscription, and
  /// this satisfies that requirement.
  static Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCatUiBridge] customer center failed: $e');
      }
      rethrow;
    }
  }
}

/// Embedded paywall widget — renders the RevenueCat-hosted paywall
/// inline inside our own Scaffold instead of as a fullscreen sheet.
/// Used by the Subscription screen at `/subscription`.
class EmbeddedPaywall extends StatelessWidget {
  final Offering? offering;
  final void Function(CustomerInfo info)? onPurchaseCompleted;
  final void Function(CustomerInfo info)? onRestoreCompleted;
  final VoidCallback? onDismiss;

  const EmbeddedPaywall({
    super.key,
    this.offering,
    this.onPurchaseCompleted,
    this.onRestoreCompleted,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return PaywallView(
      offering: offering,
      displayCloseButton: false,
      onPurchaseCompleted: (info, _) {
        onPurchaseCompleted?.call(info);
      },
      onRestoreCompleted: (info) {
        onRestoreCompleted?.call(info);
      },
      onDismiss: onDismiss,
    );
  }
}
