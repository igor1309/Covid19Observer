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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update".uppercased()),
                        footer: Text("Data by John Hopkins.")
                ) {
                    Button(action: {
                        self.coronaStore.updateCasesData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.2.circlepath")
                                .rotationEffect(.degrees(coronaStore.isCasesUpdateCompleted ? -720 : 720))
                                .animation(.easeInOut(duration: 1.3))
                                .widthPreference(column: -1)
                                .frame(width: self.columnWidths[-1], alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Update Current Data")
                                
                                Text("Last update \(coronaStore.hoursMunutesSinceCasesUpdateStr) ago")
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
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Update History Data")
                                
                                Text("Last update \(coronaStore.hoursMunutesSinceHistoryUpdateStr) ago")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                Section(header: Text("Chart and Table".uppercased()),
                        footer: Text("footer")) {
                            HStack {
                                Text("Top \(self.coronaStore.maxBars)")
                                    .padding(.trailing, 64)
                                
                                Picker(selection: $coronaStore.maxBars, label: Text("Select Top Qty")) {
                                    ForEach([10, 15, 20], id: \.self) { qty in
                                        Text("\(qty)").tag(qty)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(SegmentedPickerStyle())
                            }
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
