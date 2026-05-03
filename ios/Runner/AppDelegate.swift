import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications registers its own UNUserNotificationCenter
    // delegate via the plugin registrar — no manual wiring needed in
    // AppDelegate. The previous attempt to set the delegate here cast self
    // to UNUserNotificationCenterDelegate, which always returns nil because
    // AppDelegate doesn't conform; safer to just rely on the plugin.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
