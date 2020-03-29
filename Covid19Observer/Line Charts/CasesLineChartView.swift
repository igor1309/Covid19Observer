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
    
    @State private var numberOfGridLines = 0//10
    
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                ForEach(History.primeCountries, id: \.self)  { prime in
                    Text(prime)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top)
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Button(action: {
                    self.showModal = true
                }) {
                    HStack {
                        Text(coronaStore.selectedCountry)
                            .font(.title)
                        .lineLimit(1)
                            .layoutPriority(1)
    
                        Spacer()
                        Text(" (tap to select other country)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .sheet(isPresented: $showModal) {
                    CountryPicker().environmentObject(self.coronaStore)
                }
                
            }
            
            CountryCasesHeader()
            
            if series.isNotEmpty {
                HeatedLineChart(series: series, numberOfGridLines: numberOfGridLines)
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
        .transition(.opacity)
        .padding(.horizontal)
        .onAppear {
            self.coronaStore.updateIfStoreIsOldOrEmpty()
            
            //  MARK: FINISH THIS
            //
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.numberOfGridLines = 10
            }
        }
    }
}

struct CasesLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CasesLineChartView()
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}

