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
    
    @State private var width: CGFloat = 100
    
    var body: some View {
        Section(header: Text("Line Chart Options".uppercased()),
                footer: Text("Set Filter for Line Chart with different settiongs for Confirmed Cases and Deaths.")
        ) {
            Toggle(isOn: $settings.chartOptions.isFiltered) {
                HStack {
                    Image(systemName: "line.horizontal.3.decrease")
                        .foregroundColor(settings.chartOptions.isFiltered ? .systemOrange : .secondary)
                    
                    Text("Filter Line Chart")
                }
            }
            
            if settings.chartOptions.isFiltered {
                Group {
                    HStack {
                        Text("Confirmed")
                            .frame(width: width, alignment: .leading)
                        
                        Spacer()
                        
                        Picker("Line Chart Confirmed Limit", selection: $settings.chartOptions.confirmedLimit) {
                            ForEach([10, 50, 100, 1000], id: \.self) { qty in
                                Text(qty.formattedGrouped).tag(qty)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    HStack {
                        Text("Deaths")
                                .frame(width: width, alignment: .leading)
                        
                        Spacer()
                        
                        Picker("Line Chart Deaths Limit", selection: $settings.chartOptions.deathsLimit) {
                            ForEach([5, 10, 50, 100], id: \.self) { qty in
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
