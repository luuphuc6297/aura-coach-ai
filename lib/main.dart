import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/notification_service.dart';
import 'features/subscription/providers/subscription_provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'shared/painters/icon_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initIconRegistry();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  // Init notification scheduler before runApp so payloads from a tapped
  // notification (cold-start case) reach the GoRouter handler that gets
  // wired in `AuraCoachApp.initState`.
  await NotificationService.instance.init();

  // Configure RevenueCat as early as possible — well before any Pro
  // gate runs. The SDK persists state across launches so this is fast
  // on warm starts. Failures here are non-fatal: app still boots, and
  // `SubscriptionProvider.lastError` surfaces the issue to the paywall.
  await _configureRevenueCat();

  final prefs = await SharedPreferences.getInstance();
  runApp(AuraCoachApp(prefs: prefs));
}

/// Boots RevenueCat at app start. Kept out of [SubscriptionProvider] so
/// we don't tie SDK init to Provider lifecycle — Provider just observes
/// and reacts. The provider's own `configure()` is still called from
/// the app shell as a safety net (idempotent on the SDK side).
Future<void> _configureRevenueCat() async {
  try {
    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.debug : LogLevel.warn,
    );
    await Purchases.configure(
      PurchasesConfiguration(SubscriptionProvider.publicApiKey),
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[main] RevenueCat configure failed: $e');
    }
  }
}
