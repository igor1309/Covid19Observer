//
//  SettingsView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 24.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI
import UserNotifications

enum TimePeriod: String, CaseIterable {
    case quarterHour = "1/4h"
    case halfHour = "1/2h"
    case oneHour = "1h"
    case twoHours = "2h"
    case threeHours = "3h"
    
    var id: String { rawValue }
    
    var period: TimeInterval {
        switch self {
        case .quarterHour:
            return 15 * 60
        case .halfHour:
            return 30 * 60
        case .oneHour:
            return 60 * 60
        case .twoHours:
            return 2 * 60 * 60
        case .threeHours:
            return 3 * 60 * 60
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var isNotificationsRequestGranted = false
    @State private var notificationsRequestResponce = ""
    @State private var isNotificationSheduled = false
    @State private var notificationsSheduleResponce = ""

    let maxBarsOptions = [10, 15, 20, 100]
    let lowerLimits: [Int] = [100, 500, 1_000, 5_000, 10_000]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update".uppercased()),
                        footer: Text("Data by John Hopkins.")
                ) {
                    Button(action: {
                        self.coronaStore.updateCasesData() { _ in }
                    }) {
                        HStack {
                            Image(systemName: "arrow.2.circlepath")
                                .rotationEffect(.degrees(coronaStore.isCasesUpdateCompleted ? -720 : 720))
                                .animation(.easeInOut(duration: 1.3))
                                .widthPreference(column: -1)
                                .frame(width: self.columnWidths[-1], alignment: .leading)
                                .padding(.trailing, 3)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Update Current Data")
                                
                                Text(coronaStore.hoursMunutesSinceCasesUpdateStr == "0min"
                                    ? "Updated just now"
                                    : "Last update \(coronaStore.hoursMunutesSinceCasesUpdateStr) ago")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    Button(action: {
                        self.coronaStore.updateHistoryData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.2.circlepath.circle")
                                .rotationEffect(.degrees(coronaStore.isHistoryUpdateCompleted ? -720 : 720))
                                .animation(.easeInOut(duration: 1.3))
                                .widthPreference(column: -1)
                                .frame(width: self.columnWidths[-1], alignment: .leading)
                                .padding(.trailing, 3)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Update History Data")
                                
                                Text(coronaStore.hoursMunutesSinceHistoryUpdateStr == "0min"
                                    ? "Updated just now"
                                    : "Last update \(coronaStore.hoursMunutesSinceHistoryUpdateStr) ago")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                Section(header: Text("Color Code".uppercased()),
                        footer: Text("Select number (color) as a lower limit to filter pins on the map.")) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Lower Limit for Map Filter")
                                    .foregroundColor(coronaStore.filterColor)
                                    .padding(.trailing, 64)
                                
                                HStack {
                                    ForEach(lowerLimits, id: \.self) { item in
                                        Capsule()
                                            .foregroundColor(Color(self.coronaStore.colorCode(number: item)))
                                            .padding(.horizontal, 6)
                                            .frame(height: 16)
                                            .overlay(
                                                Capsule()
                                                    .stroke(self.coronaStore.mapFilterLowerLimit == item ? Color.primary : .clear, lineWidth: 2)
                                                    .padding(.horizontal, 6)
                                        )
                                    }
                                }
                                
                                Picker(selection: $coronaStore.mapFilterLowerLimit, label: Text("Select Top Qty")) {
                                    ForEach(lowerLimits, id: \.self) { qty in
                                        Text("\(qty)").tag(qty)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 2)
                }
                
                Section(header: Text("Notifications".uppercased()),
                        footer: Text("Regular local notifications to get updated.")) {
                            Toggle("Repeat Notifications", isOn: $settings.isNotificationRepeated)
                            
                            HStack {
                                Text(settings.isNotificationRepeated ? "Every" : "In")
                                
                                Picker(selection: $settings.selectedTimePeriod, label: Text("Time Period Selection")) {
                                    ForEach(TimePeriod.allCases, id: \.self) { period in
                                        Text(period.id).tag(period)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            if isNotificationSheduled {
                                Text(notificationsSheduleResponce)
                                    .foregroundColor(.systemGreen)
                                    .padding(.vertical, 4)
                            } else {
                                Button("Schedule Notifications") {
                                    self.scheduleNotifications()
                                }
                            }
                            
                            Group {
                                if notificationsRequestResponce.isNotEmpty {
                                    Text(notificationsRequestResponce)
                                        .foregroundColor(isNotificationsRequestGranted ? .systemGreen : .secondary)
                                }
                                
                                Button("Request Permission") {
                                    self.requestPermission()
                                }
                            }
                }
            }
            .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications Request Permission Granted")
                self.isNotificationsRequestGranted = true
                self.notificationsRequestResponce = "Notifications Request Granted"
            } else if let error = error {
                print(error.localizedDescription)
                self.isNotificationsRequestGranted = false
                self.notificationsRequestResponce = "…………"
            } else {
                print("go to settings app")
                self.isNotificationsRequestGranted = false
                self.notificationsRequestResponce = "Notifications are not allowed. Please open Setting app/Notifications/Covid19 Observer to change that."
            }
        }
    }
    
    private func scheduleNotifications() {
        /// https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
        let content = UNMutableNotificationContent()
        content.title = "Updated…"
        content.subtitle = Date().toString(format: "dd-MM-yy hh:ss")
        print(Date().toString(format: "dd.MM.yyyy hh:ss"))
        content.sound = UNNotificationSound.default
        
        // show this notification __ seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: settings.selectedTimePeriod.period,
            repeats: settings.isNotificationRepeated)

        notificationsSheduleResponce = "Notification\(settings.isNotificationRepeated ? "(s)" : "") Sheduled \(settings.isNotificationRepeated ? "to repeat every" : "one time in") \(settings.selectedTimePeriod.id) (\(settings.selectedTimePeriod.period.formattedGrouped) sec)."
        print(notificationsSheduleResponce)
        
        // choose a random identifier
        //  The request combines the content and trigger, but also adds a unique identifier so you can edit or remove specific alerts later on. If you don’t want to edit or remove stuff, use UUID().uuidString to get a random identifier.
        //        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        let identifier = "covid-19-cases-observer-updates"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        isNotificationSheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isNotificationSheduled = false
            self.notificationsSheduleResponce = ""
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CoronaStore())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
