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
    @EnvironmentObject var jhData: JohnsHopkinsData
    
    @State private var showModal = false

    var series: [Int] {
        jhData.cases.series(for: jhData.selectedCountry)
    }
    
    let numberOfGridLines = 10
    
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Picker(selection: $jhData.selectedCountry, label: Text("Selected Country")) {
                    ForEach(Cases.primeCountries, id: \.self)  { prime in
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
                    Button(jhData.selectedCountry) {
                        self.showModal = true
                    }
                    LeadingButtonSFSymbol("arrow.clockwise") {
                        self.jhData.getData()
                    }
                },
                trailing:
//                TrailingButtonSFSymbol("arrow.clockwise") {
//                    self.jhData.getData()
//                }

                Button("Done") {
                    self.presentation.wrappedValue.dismiss()
                }
            )
                .sheet(isPresented: $showModal) {
                    CountryPicker().environmentObject(self.jhData)
            }
        }
        .onAppear {
            self.jhData.getData()
        }
    }
}

struct CasesLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        CasesLineChartView()
            .environmentObject(JohnsHopkinsData())
            .environment(\.colorScheme, .dark)
    }
}
