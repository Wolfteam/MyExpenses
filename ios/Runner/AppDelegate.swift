import UIKit
import Flutter
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
    }
    
    override func applicationDidFinishLaunching(_ application: UIApplication) {
        //each hour
        let frequency = NSNumber(value: 60 * 60)
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "my_expenses_sync_task",
            frequency: frequency
        )
    
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "my_expenses_recurring_trans_task",
            frequency: frequency
        )
    }
}
