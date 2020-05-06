//
//  NotificationDelegate.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 31.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        registerNotificationCategories()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        //  MARK: - FINISH THIS
        //  open Notification settings view
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "show" {
            print("Notification action Show")
        }
        
        if response.actionIdentifier == "done" {
            print("Notification action Done")
        }
        
        completionHandler()
    }
    
    
    /// https://medium.com/flawless-app-stories/local-notifications-in-swift-5-and-ios-13-with-unusernotificationcenter-190e654a5615
    /// how to handle a notification that arrived while the app was running in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
    
    /// https://www.hackingwithswift.com/read/21/3/acting-on-responses
    func registerNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        //        center.delegate = self
        
        let showAction = UNNotificationAction(
            identifier: "show",
            title: "Tell me more…",
            options: .foreground)
        let doneAction = UNNotificationAction(
            identifier: "done",
            title: "Done",
            options: [])
        //        let commentAction = UNTextInputNotificationAction(
        //            identifier: "comment-action",
        //            title: "Comment",
        //            options: [],
        //            textInputButtonTitle: "Comment",
        //            textInputPlaceholder: "Type here…")
        
        let category = UNNotificationCategory(
            identifier: "casesUpdate",
            actions: [showAction, doneAction],//[showAction, commentAction],
            intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
}
