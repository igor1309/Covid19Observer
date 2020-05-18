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
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var isNotificationsRequestGranted = false
    @State private var notificationsRequestResponce = ""
    @State private var isNotificationSheduled = false
    @State private var notificationsSheduleResponce = ""
    
    @State private var alertStatus: AlertsStatus = .notDetermined
    
    let maxBarsOptions = [10, 15, 20, 100]
    
    
    //  MARK: - TESTING
    //
    @State private var isShowingNotificationSettingsTESTING = false
    @State private var showDoublingTime = false
    
    var doublingSection: some View {
        Section(/*header: Text("Doubling Time".uppercased()),*/
        footer: Text("Show Doubling Time: time it takes for a population to double in size/value.")) {
            Button("Doubling Time") {
                self.showDoublingTime = true
            }
            .sheet(isPresented: $showDoublingTime) {
                DoublingTimeView()
                    .environmentObject(self.settings)
            }
        }
    }
    
    @State private var showPopulation = false
    var populationSection: some View {
        Section(/*header: Text("Population".uppercased()),*/
        footer: Text("World population with search and filter.")) {
            Button("Population") {
                self.showPopulation = true
            }
            .sheet(isPresented: $showPopulation) {
                PopulationView2()
                    .environmentObject(PopulationStore())
                    .environmentObject(self.store)
                    .environmentObject(self.settings)
            }
        }
    }
    
    @State private var showSelectedCountries = false
    var primeCountriesSection: some View {
        Section(/*header: Text("Population".uppercased()),*/
        footer: Text("Select countries for Line Chart Quick Access.")) {
            Button("Prime Countries") {
                self.showSelectedCountries = true
            }
            .sheet(isPresented: $showSelectedCountries) {
                SelectedCountriesView()
                    .environmentObject(self.store)
                    .environmentObject(self.settings)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                doublingSection
                
                populationSection
                
                primeCountriesSection
                
                LineChartSettingsSection()
                
                //  MARK: FINISH THIS
                //  mase saved settings var
                Section(header: Text("Auto/Background Update".uppercased()).foregroundColor(.systemRed),
                        footer: Text("Current data updates regularly, historical once a day around 23:59 (UTC)").foregroundColor(.systemRed)
                ) {
                    /// https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data
                    HStack {
                        Text("Every")
                        
                        Picker(selection: .constant(TimePeriod.oneHour), label: Text("Update every")) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.id).tag(period)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(/*header: Text("Notifications".uppercased()),*/
                    footer: Text("Regular local notifications to get updated.")
                ) {
                    
                    NavigationLink(destination: NotificationsSettingsView(), isActive: $isShowingNotificationSettingsTESTING
                    ) {
                        Text("Notifications")
                    }
                }
                
                UpdateSection()
                
                MapColorCodeSection()
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
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
    }
}

