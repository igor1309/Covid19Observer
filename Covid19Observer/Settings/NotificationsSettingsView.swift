//
//  NotificationsSettingsView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 31.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @State private var isToggle = true
    @State private var selectedPeriod: TimePeriod = .twoHours
    
    var body: some View {
        Form {
            Section(header: Text("Notifications".uppercased()),
                    footer: Text("Set Notifications Options.")) {
                        
                        //  MARK: - FINISH THIS
                        //
                        
                        NotificationSettingRow(
                            title: "Periodic Updates",
                            subtitle: "Every hour/…/… - select below",
                            image: Image(systemName: "chart.bar"),
                            isOn: $isToggle)
                        //  MARK: if toggle is off - remove all scheduled!!!
                        
                        if isToggle {
                            Group {
                                HStack {
                                    Text("Every ")
                                    
                                    Picker(selection: $selectedPeriod, label: Text("Notify me every")) {
                                        ForEach(TimePeriod.allCases, id: \.self) { period in
                                            Text(period.id).tag(period)
                                        }
                                    }
                                    .labelsHidden()
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                        }
                        
                        NotificationSettingRow(
                            title: "Other Updates",
                            subtitle: "All things important",
                            image: Image(systemName: "square.grid.4x3.fill"),
                            isOn: .constant(false))
                        
                        NotificationSettingRow(
                            title: "Misc. Updates",
                            subtitle: "Not really important things",
                            image: Image(systemName: "cloud.rain"),
                            isOn: .constant(true))
            }
        }
    }
}

struct NotificationsSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationsSettingsView()
        }
        .environment(\.colorScheme, .dark)
    }
}

struct NotificationSettingRow: View {
    var title: String
    var subtitle: String
    var image: Image
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                image
                    .frame(width: 24, alignment: .leading)
                    .padding(.trailing, 3)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                    
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
}
