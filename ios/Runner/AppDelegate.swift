import UIKit
import Flutter
import workmanager


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
        //Each 720 min aka 12 hrs
        UIApplication.shared.setMinimumBackgroundFetchInterval(60 * 720)
        WorkmanagerPlugin.registerTask(withIdentifier: "my_expenses_sync_task")
        WorkmanagerPlugin.registerTask(withIdentifier: "my_expenses_recurring_trans_task")
        
        AppDelegate.registerPlugins(with: self) // Register the app's plugins in the context of a normal run
        
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            // The following code will be called upon WorkmanagerPlugin's registration.
            // Note : all of the app's plugins may not be required in this context ;
            // instead of using GeneratedPluginRegistrant.register(with: registry),
            // you may want to register only specific plugins.
            AppDelegate.registerPlugins(with: registry)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
    }
}
