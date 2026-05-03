import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

/// Coordinates everything subscription-related between RevenueCat's SDK
/// and the rest of the app. Owns:
///
/// - One-time SDK configuration (idempotent)
/// - The current [CustomerInfo] cache, kept fresh via the SDK's update
///   listener so the UI re-renders the moment a purchase / renewal /
///   refund event lands without us polling
/// - The current [Offerings] (paywall packages) so the paywall doesn't
///   have to fetch them on every open
/// - `login` / `logout` methods called by [AuthProvider] when the user
///   signs in or out — wires the RevenueCat appUserID to the Firebase
///   UID so receipts attach to the right account across devices
/// - `purchasePackage` / `restorePurchases` wrappers with cancellation
///   handling and clean error surfacing for the paywall UI to consume
///
/// Pro entitlement identifier is **"Aura Coach Pro"** — must match the
/// entitlement you created in the RevenueCat dashboard exactly.
class SubscriptionProvider extends ChangeNotifier {
  /// Entitlement identifier configured on the RevenueCat dashboard. The
  /// SDK looks this up inside `customerInfo.entitlements.active` to
  /// decide if Pro is unlocked.
  static const String proEntitlementId = 'Aura Coach Pro';

  /// Test/public API key. Safe to ship in client (RevenueCat treats it
  /// as a public token — server-side actions still require the secret
  /// key on the dashboard / webhook).
  ///
  /// In production, the iOS + Android keys should be different. Replace
  /// this constant with platform-specific keys read from a secret
  /// service (or `flutter_dotenv`) once the sandbox phase is over.
  static const String publicApiKey = 'test_JHlZAXibjgKpdlshPLWgDXPOSvy';

  CustomerInfo? _customerInfo;
  Offerings? _offerings;
  bool _initialized = false;
  bool _bootstrapping = false;
  String? _lastError;

  /// Late-bound listener handle so we can detach in `dispose`.
  // ignore: unused_field
  void Function(CustomerInfo)? _customerInfoListener;

  // ── public getters ─────────────────────────────────────────────────

  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;

  /// The current "default" offering surfaced on the paywall — typically
  /// has Monthly / Three-Month / Yearly packages. Null if RevenueCat
  /// hasn't returned offerings yet (e.g. first launch with no network).
  Offering? get currentOffering => _offerings?.current;

  bool get initialized => _initialized;
  String? get lastError => _lastError;

  /// True iff the user has the "Aura Coach Pro" entitlement active. This
  /// is the single boolean the rest of the app should check when gating
  /// Pro features.
  bool get isPro {
    final info = _customerInfo;
    if (info == null) return false;
    return info.entitlements.active.containsKey(proEntitlementId);
  }

  /// Period end of the active Pro entitlement. Null when free, or for
  /// non-renewing lifetime grants.
  DateTime? get proExpiresAt {
    final ent = _customerInfo?.entitlements.active[proEntitlementId];
    final raw = ent?.expirationDate;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// True while the user is in the App Store / Play Store-managed free
  /// trial window — the paywall can hide trial badges accordingly.
  bool get isInFreeTrial {
    final ent = _customerInfo?.entitlements.active[proEntitlementId];
    return ent?.periodType == PeriodType.trial;
  }

  /// Active product identifier (e.g. `monthly`, `yearly`, `three_month`)
  /// for surfaces that need to display the current plan name.
  String? get activeProductId =>
      _customerInfo?.entitlements.active[proEntitlementId]?.productIdentifier;

  // ── lifecycle ──────────────────────────────────────────────────────

  /// Boot the SDK once at app start. Safe to call multiple times — only
  /// the first call hits the SDK. Awaits offerings + customerInfo so
  /// callers can render the paywall immediately after.
  Future<void> configure() async {
    if (_initialized) return;
    if (_bootstrapping) return;
    _bootstrapping = true;

    try {
      // RevenueCat's recommended setup: configure with the public key
      // before any other Purchases call. The SDK persists the
      // configuration so subsequent app launches don't need a fresh
      // network round-trip to identify the user.
      final config = PurchasesConfiguration(publicApiKey);
      await Purchases.configure(config);

      // Quieter logs in release; fuller logs while debugging payment
      // flows during development.
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.warn,
      );

      // Live entitlement updates: SDK pings us whenever the receipt
      // changes (purchase, renewal, refund, family-sharing, server
      // webhook update). UI rebuilds via notifyListeners.
      _customerInfoListener = _handleCustomerInfoUpdate;
      Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);

      _initialized = true;
      await _refreshAll();
    } on PlatformException catch (e) {
      _lastError = 'RevenueCat configure failed: ${e.message ?? e.code}';
      if (kDebugMode) {
        debugPrint('[SubscriptionProvider] $_lastError');
      }
    } catch (e) {
      _lastError = 'RevenueCat configure failed: $e';
      if (kDebugMode) debugPrint('[SubscriptionProvider] $_lastError');
    } finally {
      _bootstrapping = false;
      notifyListeners();
    }
  }

  /// Wire the RevenueCat appUserID to a stable Firebase UID after sign-
  /// in. Idempotent — safe to call on every auth change. RevenueCat
  /// handles merging anonymous purchases into the new identity.
  Future<void> login(String uid) async {
    if (!_initialized) return;
    if (uid.isEmpty) return;
    try {
      final result = await Purchases.logIn(uid);
      _customerInfo = result.customerInfo;
      // Offerings can be region- or A/B-targeted on a per-user basis,
      // so we re-fetch after identifying the user.
      _offerings = await Purchases.getOfferings();
      _lastError = null;
    } on PlatformException catch (e) {
      _lastError = 'Login failed: ${e.message ?? e.code}';
    } finally {
      notifyListeners();
    }
  }

  /// Detach RevenueCat from the previous user on Firebase sign-out so
  /// the next anonymous user doesn't inherit the old identity.
  Future<void> logout() async {
    if (!_initialized) return;
    try {
      _customerInfo = await Purchases.logOut();
      _lastError = null;
    } on PlatformException catch (e) {
      // RevenueCat throws if the current user is already anonymous.
      // That's fine — log and move on.
      if (kDebugMode) {
        debugPrint('[SubscriptionProvider] logout: ${e.message ?? e.code}');
      }
    } finally {
      notifyListeners();
    }
  }

  // ── purchase / restore ─────────────────────────────────────────────

  /// Purchase a [Package]. Returns true if the resulting receipt grants
  /// the Pro entitlement, false otherwise. User-cancellation is treated
  /// as a non-error and returns false silently (UI just dismisses the
  /// purchase sheet).
  Future<bool> purchasePackage(Package package) async {
    try {
      _lastError = null;
      final info = await Purchases.purchasePackage(package);
      _customerInfo = info;
      notifyListeners();
      return info.entitlements.active.containsKey(proEntitlementId);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        // User dismissed the StoreKit / Play Billing sheet — not an
        // error worth showing.
        return false;
      }
      _lastError = e.message ?? code.name;
      notifyListeners();
      return false;
    }
  }

  /// Re-attach receipts already attached to the device's Apple / Google
  /// account. App Store / Play Store policy require this for users
  /// reinstalling after deleting the app.
  Future<bool> restorePurchases() async {
    try {
      _lastError = null;
      _customerInfo = await Purchases.restorePurchases();
      notifyListeners();
      return isPro;
    } on PlatformException catch (e) {
      _lastError = e.message ?? e.code;
      notifyListeners();
      return false;
    }
  }

  /// Manual refresh for "pull-to-refresh" affordances or after coming
  /// back from a manage-subscription deep link.
  Future<void> refresh() async {
    if (!_initialized) return;
    await _refreshAll();
  }

  // ── platform helpers ───────────────────────────────────────────────

  /// True if the active platform supports IAP at all. Useful for the
  /// paywall to render a "not available on this platform" state on
  /// macOS desktop builds, the web, etc.
  bool get isPurchasingSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  // ── internals ──────────────────────────────────────────────────────

  Future<void> _refreshAll() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _customerInfo = info;
    } catch (_) {
      // Network blip on launch — keep whatever cache we already have.
    }
    try {
      _offerings = await Purchases.getOfferings();
    } catch (_) {
      // Offerings not configured yet on the dashboard, or offline.
      // Paywall will fall back to its empty state.
    }
    notifyListeners();
  }

  void _handleCustomerInfoUpdate(CustomerInfo info) {
    _customerInfo = info;
    notifyListeners();
  }

  @override
  void dispose() {
    final listener = _customerInfoListener;
    if (listener != null) {
      Purchases.removeCustomerInfoUpdateListener(listener);
    }
    super.dispose();
  }
}
