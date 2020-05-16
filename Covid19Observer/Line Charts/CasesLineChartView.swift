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
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    var forAllCountries: Bool
    
    @State private var showCountryPickerTable = false
    @State private var showTable = false
    
    var countryPicker: some View {
        HStack {
            Button(action: {
                self.showCountryPickerTable = true
            }) {
                HStack {
                    Image(systemName: "chevron.down")
                        .font(.headline)
                    
                    Text(store.selectedCountry)
                        .font(.title)
                        .lineLimit(1)
                        .layoutPriority(1)
                }
            }
            .sheet(isPresented: $showCountryPickerTable) {
                CountryPicker()
                    .environmentObject(self.store)
                    .environmentObject(self.settings)
            }
            .layoutPriority(1)
            
            Spacer()
        }
    }
    
    var primeCountryToggle: some View {
        let isInSelected = settings.primeCountries.map { $0.name }.contains(store.selectedCountry)
        
        return ToolBarButton(systemName: isInSelected ? "star.fill" : "star") {
            if isInSelected {
                let index = self.settings.primeCountries.firstIndex { $0.name == self.store.selectedCountry }!
                self.settings.primeCountries.remove(at: index)
            } else {
                let iso2 = self.store.countriesWithIso2[self.store.selectedCountry]!
                self.settings.primeCountries.append(Country(name: self.store.selectedCountry, iso2: iso2))
            }
        }
        .foregroundColor(isInSelected ? .systemOrange : .secondary)
        .font(.subheadline)
    }
    
    var header: some View {
        return Group {
            if forAllCountries {
                Text("All Countries \(settings.chartOptions.dataKind.id)")
                    .foregroundColor(.systemOrange)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 6)
                
                settings.chartOptions.dataKind == .cfr
                    ? Text("TO BE DONE")
                        .foregroundColor(.red)
                        .font(.title)
                    : nil
                
            } else {
                PrimeCountryPicker(selection: $store.selectedCountry)
                
                ZStack(alignment: .trailing) {
                    countryPicker
                    primeCountryToggle
                }
                
                ZStack(alignment: .topTrailing) {
                    Dashboard(outbreak: store.selectedCountryOutbreak, forAllCountries: false)
                    
                    VStack {
                        AppendCurrentToggle()
                        
                        ToolBarButton(systemName: "table") {
                            self.showTable = true
                        }
                        .sheet(isPresented: $showTable) {
                            CountryDataTable(series: self.series)
                                .environmentObject(self.store)
                        }
                    }
                }
            }
        }
    }
    
    var series: [Int] {
        store
            .series(for: settings.chartOptions.dataKind,
                    appendCurrent: settings.chartOptions.appendCurrent,
                    forAllCountries: forAllCountries)
            .filtered(limit: settings.chartOptions.lineChartLimit)
    }
    
    var callToUpdate: some View {
        ZStack {
            Color.quaternarySystemFill
            
            VStack {
                Text ("No Data to display.")
                    .foregroundColor(.secondary)
                    .font(.headline)
                
                if self.settings.chartOptions.isFiltered {
                    Text ("Please check the filter.")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    LineChartFilterToggle()
                }
                
                SpinningWaitHistoryButton()
            }
        }
    }
    
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            header
            
            if series.isNotEmpty {
                
                DataKindPicker(selectedDataKind: $settings.chartOptions.dataKind)
                    .padding(.vertical, 6)
                
                Text(settings.chartOptions.dataKind.rawValue)
                    .foregroundColor(settings.chartOptions.dataKind.color)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ZStack(alignment: .topLeading) {
                    HeatedLineChart(series: series)
                    
                    //    LineChartFilterToggle()
                    //        .padding(.top, 6)
                }
                
            } else {
                callToUpdate
            }
        }
        .padding(.top)
        .transition(.opacity)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}

struct CasesLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                CasesLineChartView(forAllCountries: false)
            }
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                CasesLineChartView(forAllCountries: true)
            }
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}

