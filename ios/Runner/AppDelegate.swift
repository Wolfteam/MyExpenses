import UIKit
import Flutter
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
    /// Registers all pubspec-referenced Flutter plugins in the given registry.
    static func registerPlugins(with registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        AppDelegate.registerPlugins(with: self) // Register the app's plugins in the context of a normal run
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
