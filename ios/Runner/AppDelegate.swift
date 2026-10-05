import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // flutter_local_notifications: بدونه لا تظهر الإشعارات والتطبيق مفتوح (iOS 10+).
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    setUpWidgetChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// جسر الودجت: Dart (lib/services/widget_sync_service.dart) يرسل لقطة JSON
  /// فنحفظها في Keychain المشترك ونطلب من النظام تحديث الودجتات.
  private func setUpWidgetChannel() {
    guard let messenger = registrar(forPlugin: "RuqyahWidgetBridge")?.messenger() else { return }
    let channel = FlutterMethodChannel(name: "com.ruqyah.altatil/widget", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "update":
        guard let json = call.arguments as? String, let data = json.data(using: .utf8) else {
          result(FlutterError(code: "bad_args", message: "expected a JSON string", details: nil))
          return
        }
        let saved = WidgetStore.write(data)
        if saved, #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(saved)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
