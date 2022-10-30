import UIKit
import Flutter
import workmanager


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    //WorkmanagerPlugin.registerTask(withIdentifier: "my_expenses_sync_task")
    //WorkmanagerPlugin.registerTask(withIdentifier: "my_expenses_recurring_trans_task")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
