//
//  NotificationsPermissions.swift
//  Neighborhood Alerts
//
//  From: https://developerhowto.com/2018/12/07/implement-push-notifications-in-ios-with-swift/
//

import UIKit
import UserNotifications

extension UIViewController {
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("User Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func requestNotificationAuthorization(){
        // Request for permissions
        UNUserNotificationCenter.current()
            .requestAuthorization(
            options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                //print("Notification granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
}


extension AppDelegate {
    
    // for debug purposes
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map
            { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("DEBUG - Device token for push notifications: \(token)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error registering notifications: \(error)")
    }
    
    func getNotificationSettingsThenRegister() {
        UNUserNotificationCenter.current().getNotificationSettings {
            //This closure definition gets access to push notification settings
            settings in
            
            //Here we check if the user authorized push notifications
            //If the user refused push notification auth, then this will exit early
            guard settings.authorizationStatus == .authorized else {return}
            
            //We pop the registration code onto the main queue as recommended by Apple
            DispatchQueue.main.async {
                
                //Here we attempt to register for remote push notifications
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
   func registerForPushNotifications() {
        //Here we are creating a notifCenter reference for shorter lines of code
        let notifCenter = UNUserNotificationCenter.current()

        //Here we access the requestAuthorization method that lives on the
        //UNUserNotificationCenter.  It takes an array of options of an enum type
        //and a closure as arguments.
        notifCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            //Here are two values that we have access to in the closure definition
            //Access Granted (Bool) is true if the user gave permission to use push
            //notifications.
            accessGranted, error in

                //Call the other function we defined
                self.getNotificationSettingsThenRegister()
       }
   }
}
