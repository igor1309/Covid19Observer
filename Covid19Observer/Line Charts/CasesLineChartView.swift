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
                HStack {
                    Text("Confirmed: \(coronaStore.selectedCountryOutbreak.totalCases)")
                        .foregroundColor(.systemYellow)
                    
                    Spacer()
                    
                    Text("Deaths: \(coronaStore.selectedCountryOutbreak.totalDeaths)")
                        .foregroundColor(.systemRed)
                }
                
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
                
                Text(series
                    .suffix(14)
                    .map { String($0) }
                    .joined(separator: ", ")
                    //  MARK: FINISH THIS
                    //  показать последюнюю дату в серии
                    //+ " " + coronaStore.history.rows[0].series.last
                )
                    .foregroundColor(.tertiary)
                    .font(.caption)
                    .padding(.bottom, 6)
            }
            .padding(.horizontal)
            .onAppear {
                self.coronaStore.updateIfStoreIsOldOrEmpty()
            }
                
            .navigationBarTitle("\(coronaStore.selectedCountry)")
            .navigationBarItems(leading:
                Button(coronaStore.selectedCountry + " ⌄") {
                    self.showModal = true
                }
                .sheet(isPresented: $showModal) {
                    CountryPicker().environmentObject(self.coronaStore)
                }
            )
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
