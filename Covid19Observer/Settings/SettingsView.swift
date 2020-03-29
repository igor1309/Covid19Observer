//
//  SettingsView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 24.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct SettingsView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @State private var columnWidths: [Int: CGFloat] = [:]
    
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
                            VStack(alignment: .leading) {
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
            }
            .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
