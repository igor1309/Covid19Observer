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

struct SettingsView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var isNotificationsRequestGranted = false
    @State private var notificationsRequestResponce = ""
    @State private var isNotificationSheduled = false
    @State private var notificationsSheduleResponce = ""
    
    @State private var alertStatus: AlertsStatus = .notDetermined
    
    let maxBarsOptions = [10, 15, 20, 100]
    let lowerLimits: [Int] = [100, 500, 1_000, 5_000, 10_000]
    
    
    //  MARK: - TESTING
    //
    @State private var isShowingNotificationSettingsTESTING = false
    
    var body: some View {
        NavigationView {
            Form {
                LineChartSettingsSection()
                
                //  MARK: FINISH THIS
                //  mase saved settings var
                Section(header: Text("Auto/Background Update".uppercased()).foregroundColor(.systemRed),
                        footer: Text("Current data updates regularly, historical once a day around 23:59 (UTC)").foregroundColor(.systemRed)
                ) {
                    /// https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data
                    HStack {
                        Text("Every...")
                        
                        Picker(selection: .constant(TimePeriod.oneHour), label: Text("Update every")) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.id).tag(period)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Notifications".uppercased()),
                        footer: Text("Regular local notifications to get updated.")
                ) {
                    
                    NavigationLink(destination: NotificationsSettingsView()
                        ,
                                   isActive: $isShowingNotificationSettingsTESTING
                    ) {
                        Text("Notifications")
                    }
                    
                    NotificationSettingsSection()
                }
                
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
                                
                                Text(coronaStore.timeSinceCasesUpdateStr == "0min"
                                    ? "Updated just now"
                                    : "Last update \(coronaStore.timeSinceCasesUpdateStr) ago")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    Button(action: {
                        self.coronaStore.updateHistoryData() { }
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
                                
                                Text(coronaStore.timeSinceHistoryUpdateStr == "0min"
                                    ? "Updated just now"
                                    : "Last update \(coronaStore.timeSinceHistoryUpdateStr) ago")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                Section(header: Text("Map Color Code".uppercased()),
                        footer: Text("Select number (color) as a lower limit to filter pins on the map.")
                ) {
                    //                            VStack(alignment: .leading, spacing: 12) {
                    Group {
                        Text("Lower Limit for Map Filter")
                            .foregroundColor(coronaStore.filterColor)
                            .padding(.trailing, 64)
                        
                        HStack {
                            ForEach(lowerLimits, id: \.self) { item in
                                Capsule()
                                    .foregroundColor(Color(self.coronaStore.colorCode(for: item)))
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
            }
            .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
