//
//  NotificationSettingsSection.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 30.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

enum AlertsStatus {
    case notDetermined, denied, scheduled, new
}

struct NotificationSettingsSection: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var notificationsSettings: NotificationsSettings
    
    @State private var status: AlertsStatus = .scheduled
    
    private var deniedAlertView: some View {
        Group {
            Button("Alerts in Notifications are not allowed.") {
                self.checkAuthorizationStatus()
            }
            
            Text("Please open Setting app / Notifications / Covid19 Observer to change that.")
                .foregroundColor(.secondary)
            
            Button("Open Settings App") {
                self.openSettingsApp()
            }
        }
    }
    
    private func openSettingsApp() {
        DispatchQueue.main.async {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsURL, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    UIApplication.shared.openURL(settingsURL as URL)
                }
                self.status = .notDetermined
            }
        }
    }
    
    private var newAlertView: some View {
        Group {
            Toggle("Repeat Notifications", isOn: $notificationsSettings.repeatNotification)
            
            HStack {
                Text(notificationsSettings.repeatNotification ? "Every" : "Once in")
                
                Picker(selection: $notificationsSettings.selectedTimePeriod, label: Text("Time Period Selection")) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.id).tag(period)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("Schedule Notification") {
                self.scheduleAlert()
            }
        }
    }
    
    private func scheduleAlert() {
        /// Apple: Always check your app’s authorization status before scheduling local notifications. Users can change your app’s authorization settings at any time. They can also change the type of interactions allowed by your app—which may cause you to alter the number or type of notifications your app sends.
        /// https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            self.parseNotificationSettings(settings)
            
            guard (settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional)
                && settings.alertSetting == .enabled else { return }
            
            self.createAndAddAlert()
            self.checkPendingNotifications()
        }
    }
    
    private func createAndAddAlert() {
        
        let outbreak = self.coronaStore.outbreak
        /// https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
        let content = UNMutableNotificationContent()
        content.title = "Updated"
        content.subtitle = Date().toString(format: "dd.MM.yyyy h:ss")
        content.body = "Total Confirmed: \(outbreak.confirmedStr)\nTotal Deaths: \(outbreak.deathsStr)\nCase Fatality Rate: \(outbreak.cfrStr)"
        /// https://www.hackingwithswift.com/read/21/2/scheduling-notifications-unusernotificationcenter-and-unnotificationrequest
        content.categoryIdentifier = "casesUpdate"
        content.sound = UNNotificationSound.default
        /// https://www.hackingwithswift.com/example-code/system/how-to-group-user-notifications-using-threadidentifier-and-summaryargument
        content.threadIdentifier = "covid-19-cases-observer-updates"
        
        
        //  show this notification __ seconds from now
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: self.notificationsSettings.selectedTimePeriod.period,
            repeats: self.notificationsSettings.repeatNotification)
        
        
        //  choose a random identifier
        //  The request combines the content and trigger, but also adds a unique identifier so you can edit or remove specific alerts later on. If you don’t want to edit or remove stuff, use UUID().uuidString to get a random identifier.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //            let identifier = "covid-19-cases-observer-updates"
        //            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
            print("Scheduling notification with id: \(request.identifier)")
        }
        
        DispatchQueue.main.async {
            self.status = .scheduled
            self.notificationsSettings.isAlertScheduled = true
            self.notificationsSettings.notificationWasScheduledAt = Date()
        }
    }
    
    //  MARK: - FINISH THIS
    /// https://www.hackingwithswift.com/read/21/3/acting-on-responses
    //    func registerCategories() {
    //        let center = UNUserNotificationCenter.current()
    //        //        center.delegate = self
    //
    //        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
    //        let category = UNNotificationCategory(identifier: "casesUpdate", actions: [show], intentIdentifiers: [])
    //
    //        center.setNotificationCategories([category])
    //    }
    
    
    //  MARK: - FINISH THIS
    /// https://www.hackingwithswift.com/read/21/3/acting-on-responses
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //        // pull out the buried userInfo dictionary
    //        let userInfo = response.notification.request.content.userInfo
    //
    //        if let customData = userInfo["customData"] as? String {
    //            print("Custom data received: \(customData)")
    //
    //            switch response.actionIdentifier {
    //            case UNNotificationDefaultActionIdentifier:
    //                // the user swiped to unlock
    //                print("Default identifier")
    //
    //            case "show":
    //                // the user tapped our "show more info…" button
    //                print("Show more information…")
    //
    //            default:
    //                break
    //            }
    //        }
    //
    //        // you must call the completion handler when you're done
    //        completionHandler()
    //    }
    
    
    private var notDeterminedView: some View {
        Button("Request permission") {
            self.requestPermission()
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]) { success, error in
                
                self.checkAuthorizationStatus()
        }
    }
    
    @State private var showResetAlert = false
    
    private var scheduledAlertView: some View {
        Group {
            Text("Notification\(notificationsSettings.repeatNotification ? "s were" : " was") scheduled \(notificationsSettings.timeSinceScheduled) ago \(notificationsSettings.repeatNotification ? "to repeat every" : "for one time in") \(notificationsSettings.selectedTimePeriod.id) (\(notificationsSettings.selectedTimePeriod.period.formattedGrouped) sec).")
            
            
            Button("Create New Notification") {
                self.status = .new
            }
            
            Button("Remove all Scheduled Notifications") {
                self.showResetAlert = true
            }
            .foregroundColor(.systemRed)
            .actionSheet(isPresented: $showResetAlert) {
                ActionSheet(
                    title: Text("Delete Scheduled Notifications"),
                    message: Text("Are you sure?"),
                    buttons: [
                        .destructive(Text("Yes, delete")) {
                            self.resetScheduledNotifications()
                        },
                        .cancel()
                ])
            }
        }
    }
    
    private func resetScheduledNotifications() {
        //        let identifier = "covid-19-cases-observer-updates"
        //        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        /// reset
        self.notificationsSettings.resetAlertData()
        
        self.status = .new
        self.checkPendingNotifications()
    }
    
    private var alertView: some View {
        switch status {
        case .denied:
            return AnyView(deniedAlertView)
        case .new:
            return AnyView(newAlertView)
        case .notDetermined:
            return AnyView(notDeterminedView)
        case .scheduled:
            return AnyView(scheduledAlertView)
        }
    }
    
    @State private var pendingNotifications = ""
    private var pendingNotificationsView: some View {
        Group {
            Group {
                Text("Pending Notifications: ")
                    .foregroundColor(.secondary)
                
                Text("\(pendingNotifications.isEmpty ? "none" : pendingNotifications)")
            }
            .font(.subheadline)
            .onAppear {
                self.checkPendingNotifications()
            }
            
            Button("Get Pending Notifications") {
                self.checkPendingNotifications()
            }
        }
    }
    
    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            
            DispatchQueue.main.async {
                self.pendingNotifications = ListFormatter.localizedString(byJoining: requests.map { $0.identifier })
                self.notificationsSettings.isAlertScheduled = requests.filter { $0.identifier == "covid-19-cases-observer-updates" }.map { $0.content }.isNotEmpty
            }
        }
    }
    
    var body: some View {
        Group {
            alertView
                .onAppear {
                    self.checkAuthorizationStatus()
            }
            
            pendingNotificationsView
                .onAppear {
                    self.checkPendingNotifications()
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            self.parseNotificationSettings(settings)
        }
    }
    
    
    private func parseNotificationSettings(_ settings: UNNotificationSettings) {
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            if settings.alertSetting == .enabled {
                if self.notificationsSettings.isAlertScheduled {
                    self.status = .scheduled
                } else {
                    self.status = .new
                }
            } else {
                self.status = .denied
            }
        case .notDetermined:
            self.status = .notDetermined
        case .denied:
            self.status = .denied
        @unknown default:
            self.status = .denied
        }
    }
}

struct NotificationSettingsSection_Previews: PreviewProvider {
    @State static var status: AlertsStatus = .new
    
    static var previews: some View {
        NavigationView {
            Form {
                NotificationSettingsSection()
            }
        }
        .environmentObject(NotificationsSettings())
        .environment(\.colorScheme, .dark)
    }
}

