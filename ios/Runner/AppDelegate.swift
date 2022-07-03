import UIKit
import Flutter
import workmanager
//import flutter_local_notifications
//import shared_preferences

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
      
        //WorkmanagerPlugin.registerTask(withIdentifier: "task-identifier")

        WorkmanagerPlugin.register(with: self.registrar(forPlugin: "be.tramckrijte.workmanager.WorkmanagerPlugin")!)
        
        UNUserNotificationCenter.current().delegate = self

        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60))
      
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }

//        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
//            // registry in this case is the FlutterEngine that is created in Workmanager's performFetchWithCompletionHandler
//            // This will make other plugins available during a background fetch
//            //GeneratedPluginRegistrant.register(with: registry)
//
////            DevicelocalePlugin.register(with: registry.registrar(forPlugin: "com.example.devicelocale.DevicelocalePlugin"))
//            FlutterLocalNotificationsPlugin.register(with: registry.registrar(forPlugin: "com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin")!)
////            FLTSharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"))
//
//        }

    
    // if #available(iOS 10.0, *) {
    //   UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    // }
    // UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60/* Your Desired Interval for Background Tasks */))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

//@UIApplicationMain
//@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    GeneratedPluginRegistrant.register(with: self)
//
//   if #available(iOS 10.0, *) {
//     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//   }
//
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//}

