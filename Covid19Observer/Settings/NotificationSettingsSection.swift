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

struct DeniedAlertView: View {
    var body: some View {
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
}

struct NotificationSettingsSection: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State var status: AlertsStatus = .scheduled
    
    
    
    var newAlertView: some View {
        Group {
            Toggle("Repeat Notifications", isOn: $settings.isNotificationRepeated)
            
            HStack {
                Text(settings.isNotificationRepeated ? "Every" : "Once in")
                
                Picker(selection: $settings.selectedTimePeriod, label: Text("Time Period Selection")) {
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
            
            
            //  MARK: FINISH THIS
            //  https://www.hackingwithswift.com/read/21/3/acting-on-responses
            //  registerCategories()
            
            
            /// https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
            let content = UNMutableNotificationContent()
            content.title = "Updated"
            content.subtitle = Date().toString(format: "dd-MM-yy hh:ss")
            content.body = "Total Confirmed: \(self.coronaStore.coronaOutbreak.totalCases)\n" + "Total Deaths: \(self.coronaStore.coronaOutbreak.totalDeaths)\n" + "Case Fatality Rate: \(self.coronaStore.worldCaseFatalityRate.formattedPercentage)"
            /// https://www.hackingwithswift.com/read/21/2/scheduling-notifications-unusernotificationcenter-and-unnotificationrequest
            content.categoryIdentifier = "casesUpdate"
            content.sound = UNNotificationSound.default
            /// https://www.hackingwithswift.com/example-code/system/how-to-group-user-notifications-using-threadidentifier-and-summaryargument
            content.threadIdentifier = "covid-19-cases-observer-updates"
            
            //  show this notification __ seconds from now
            //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: self.settings.selectedTimePeriod.period,
                repeats: self.settings.isNotificationRepeated)
            
            //  choose a random identifier
            //  The request combines the content and trigger, but also adds a unique identifier so you can edit or remove specific alerts later on. If you don’t want to edit or remove stuff, use UUID().uuidString to get a random identifier.
            //  let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            let identifier = "covid-19-cases-observer-updates"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // add our notification request
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(request.identifier)")
            }
            
            self.status = .scheduled
            self.settings.isAlertScheduled = true
            self.settings.notificationWasScheduledAt = Date()
        }
    }
    
    
    //  MARK: - FINISH THIS
    /// https://www.hackingwithswift.com/read/21/3/acting-on-responses
    //    func registerCategories() {
    //        let center = UNUserNotificationCenter.current()
    //        //        center.delegate = self
    //
    //        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
    //        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
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
    
    
    var notDeterminedView: some View {
        Button("Request permission") {
            self.requestPermission()
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { success, error in
            
            self.checkAuthorizationStatus()
        }
    }
    
    @State private var showResetAlert = false
    @State private var pendingNotifications = ""
    
    var scheduledAlertView: some View {
        Group {
            Text("Notification\(settings.isNotificationRepeated ? "s were" : " was") scheduled \(settings.hoursMunutesSincenotificationWasScheduledAt) ago \(settings.isNotificationRepeated ? "to repeat every" : "for one time in") \(settings.selectedTimePeriod.id) (\(settings.selectedTimePeriod.period.formattedGrouped) sec).")
            
            
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
            
            #if DEBUG
            Spacer()
            Text("Testing:".uppercased())
            
            Group {
                Text("Pending Notification Requests: ")
                    .foregroundColor(.secondary)
                    + Text("\(pendingNotifications.isEmpty ? "none" : pendingNotifications)")
            }
            .font(.subheadline)
            .onAppear {
                self.getPending()
            }
            
            Button("Get Pending Notification Requests") {
                self.getPending()
            }
            #endif
        }
    }
    
    private func getPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            
            //                        print(requests)
            self.pendingNotifications = requests.map { $0.identifier }.joined(separator: ", ")
        }
    }
    
    private func resetScheduledNotifications() {
        let identifier = "covid-19-cases-observer-updates"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        /// reset
        self.settings.resetAlertData()
        
        self.status = .new
    }
    
    var body: some View {
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
    
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            self.parseNotificationSettings(settings)
        }
    }
    
    
    private func parseNotificationSettings(_ settings: UNNotificationSettings) {
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            if settings.alertSetting == .enabled {
                if self.settings.isAlertScheduled {
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
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}

