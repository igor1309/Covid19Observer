//
//  CasesLineChartView.swift
//  Doubling
//
//  Created by Igor Malyarov on 17.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CasesLineChartView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var showModal = false

    var series: [Int] {
        coronaStore.history.series(for: coronaStore.selectedCountry)
    }
    
    let numberOfGridLines = 10
    
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                    ForEach(History.primeCountries, id: \.self)  { prime in
                        Text(prime)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if series.isNotEmpty {
                    HeatedLineChart(series: series, numberOfGridLines: numberOfGridLines)
//                        .padding(.top, 12)
                } else {
                    Spacer()
                }
                
                Text(series.map { String($0) }.joined(separator: ", "))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .navigationBarTitle("COVID-19")
            .navigationBarItems(
                leading: HStack {
                    Button(coronaStore.selectedCountry) {
                        self.showModal = true
                    }
                    LeadingButtonSFSymbol("arrow.clockwise") {
                        self.coronaStore.getHistoryData()
                    }
                },
                trailing:
//                TrailingButtonSFSymbol("arrow.clockwise") {
//                    self.coronaStore.getHistoryData()
//                }

                Button("Done") {
                    self.presentation.wrappedValue.dismiss()
                }
            )
                .sheet(isPresented: $showModal) {
                    CountryPicker().environmentObject(self.coronaStore)
            }
        }
        .onAppear {
            self.coronaStore.getHistoryData()
        }
    }
}

struct CasesLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        CasesLineChartView()
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
