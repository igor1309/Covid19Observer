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
    @EnvironmentObject var settings: Settings
    
    @State private var showCountryPicker = false
    @State private var selectedDataKind = DataKind.total
    
    var series: [Int] {
        switch selectedDataKind {
        case .total:
            return coronaStore.history.series(for: coronaStore.selectedCountry)
        case .daily:
            return coronaStore.history.change(for: coronaStore.selectedCountry)
        }
    }
    
    @State private var numberOfGridLines = 0//10
    
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                ForEach(PrimeCountries.allCases, id: \.self)  { country in
                    Text(country.iso2).tag(country.name)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top)
            
            Button(action: {
                self.showCountryPicker = true
            }) {
                HStack {
                    Text(coronaStore.selectedCountry)
                        .font(.title)
                        .lineLimit(1)
                        .layoutPriority(1)
                    
//                    Spacer()
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.headline)
//                    Text(" (tap to select other country)")
//                        .foregroundColor(.secondary)
//                        .font(.caption)
                }
            }
            .sheet(isPresented: $showCountryPicker) {
                CountryPicker().environmentObject(self.coronaStore)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    CountryCasesHeader()
                    
                    VStack {
                        Text(coronaStore.history.last(for: coronaStore.selectedCountry).formattedGrouped)
                        Text("last in history")
                            .font(.caption)
                    }
                    .background(Color.tertiarySystemBackground)
                }
                .padding(.bottom, 4)
            }
            
            if series.isNotEmpty {
                
                DataKindPicker(selectedDataKind: $selectedDataKind)
                
                ZStack(alignment: .topLeading) {
                    HeatedLineChart(series: series.filtered(limit: settings.isLineChartFiltered ? settings.lineChartLimit : 0), numberOfGridLines: numberOfGridLines)
                    
                    ToolBarButton(systemName: "line.horizontal.3.decrease") {
                        self.settings.isLineChartFiltered.toggle()
                    }
                    .foregroundColor(settings.isLineChartFiltered ? .systemOrange : .systemBlue)
                    .padding(.top, 6)
                }
                
            } else {
                Spacer()
            }

            /// показать данные за последние 14 дней
//                Text(series
//                    .suffix(min(14, series.count))
//                    .map { String($0) }
//                    .joined(separator: ", ")
//                    //  MARK: FINISH THIS
//                    //  показать последюнюю дату в серии
//                    //+ " " + coronaStore.history.rows[0].series.last
//                )
//                    .foregroundColor(.tertiary)
//                    .font(.caption)
//                    .padding(.bottom, 6)
        }
        .transition(.opacity)
        .padding(.horizontal)
        .padding(.bottom, 6)
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
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}

