//
//  AppDelegate.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import UIKit
import BackgroundTasks

class AppRefreshOperation: Operation {
    override func main() {
        let coronaStore = CoronaStore()
        coronaStore.updateCasesData() { type in
            NotificationCenter.default.post(name: .newCasesFetched,
                                            object: type.id)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //  Notifications Delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        
        // MARK: Registering Launch Handlers for Tasks
        /// https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler
        /// https://www.andyibanez.com/posts/modern-background-tasks-ios13/
        /// https://habr.com/ru/post/466857/
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.photoigor.covid19observer.fetchCases",
            using: DispatchQueue.global()
        ) { task in
            self.handleAppRefresh(task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }
    
    // MARK: - Scheduling Tasks
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.photoigor.covid19observer.fetchCases")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60)//2 * 60 * 60) //  Fetch no earlier than __ minutes from now
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Handling Launch for Tasks
    private func handleAppRefresh(_ task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let appRefreshOperation = AppRefreshOperation()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            queue.cancelAllOperations()
        }
        
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }

        queue.addOperation(appRefreshOperation)
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
    
    
}

