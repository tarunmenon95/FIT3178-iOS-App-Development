//  AppDelegate.swift
//  bazaar

//The AppDelegate class of the app, CoreDataController is instantiated here aswell as UNNotifcation delegate functions

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var databaseController: DatabaseProtocol?
    var notificationsEnabled = false
    let CATEGORY_IDENTIFIER = "PLSWORK"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //CoreDataController
        databaseController = CoreDataController()
        
        //Tab Bar appearance
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .purple
        
        //Notification Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
                   if granted {
                       self.notificationsEnabled = granted
                       UNUserNotificationCenter.current().delegate = self
                   }
               }  
        return true
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }

}

