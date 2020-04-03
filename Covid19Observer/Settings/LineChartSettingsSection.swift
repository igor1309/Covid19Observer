//
//  LineChartSettingsSection.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 03.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct LineChartSettingsSection: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Section(header: Text("Line Chart Options".uppercased()), footer: Text("adfgdafgaf")
        ) {
            Toggle(isOn: $settings.isLineChartFiltered) {
                Text("Filter Line Chart")
            }
            
            if settings.isLineChartFiltered {
                HStack {
                    Text("Limit")
                    
                    Spacer()
                    
                    Picker("Line Chart Limit", selection: $settings.lineChartLimit) {
                        ForEach([10, 100, 1000], id: \.self) { qty in
                            Text(qty.formattedGrouped).tag(qty)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
}

struct LineChartSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                LineChartSettingsSection()
            }
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Settings())
    }
}
