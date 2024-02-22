//
//  AppDelegate.swift
//  Alarm
//
//  Created by pinali gabani on 07/12/23.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    lazy var coreDataStack: CoreDataStack = .init(modelName: "AlarmList")
    
    static let sharedAppDelegate: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unexpected app delegate type, did it change? \(String(describing: UIApplication.shared.delegate))")
        }
        return delegate
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
         ) {(accepted, error) in
           if !accepted {
             print("Notification access denied.")
           }
         }
         UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
    }
}
extension AppDelegate{
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

      completionHandler(.alert)
    }

    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void) {

      completionHandler()
    }
}
