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
    
    @State private var showCountryPickerTable = false
    
    var countryPicker: some View {
        HStack {
            Button(action: {
                self.showCountryPickerTable = true
            }) {
                HStack {
                    Text(coronaStore.selectedCountry)
                        .font(.title)
                        .lineLimit(1)
                        .layoutPriority(1)
                    
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.headline)
                }
            }
            .sheet(isPresented: $showCountryPickerTable) {
                CountryPicker()
                    .environmentObject(self.coronaStore)
                    .environmentObject(self.settings)
            }
            .layoutPriority(1)
            
            Spacer()
        }
    }
    
    var primeCountryToggle: some View {
        let isInSelected = settings.primeCountries.map { $0.name }.contains(coronaStore.selectedCountry)
        
        return ToolBarButton(systemName: isInSelected ? "star.fill" : "star") {
            if isInSelected {
                let index = self.settings.primeCountries.firstIndex { $0.name == self.coronaStore.selectedCountry }!
                self.settings.primeCountries.remove(at: index)
            } else {
                let iso2 = self.coronaStore.countriesWithIso2[self.coronaStore.selectedCountry]!
                self.settings.primeCountries.append(Country(name: self.coronaStore.selectedCountry, iso2: iso2))
            }
        }
        .foregroundColor(isInSelected ? .systemOrange : .secondary)
        .font(.subheadline)
    }
        
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {

        let series = coronaStore
            .series(for: settings.chartOptions.dataKind,
                    appendCurrent: settings.chartOptions.appendCurrent)
            .filtered(limit: settings.chartOptions.lineChartLimit)
        
        return VStack(alignment: .leading, spacing: 8) {
            
            PrimeCountryPicker(selection: $coronaStore.selectedCountry)
            
            ZStack(alignment: .trailing) {
                countryPicker
                primeCountryToggle
            }
            
            ZStack(alignment: .topTrailing) {
                Dashboard(outbreak: coronaStore.selectedCountryOutbreak, forAllCountries: false)
                
                AppendCurrentToggle()
            }
            
            if series.isNotEmpty {
                
                DataKindPicker(selectedDataKind: $settings.chartOptions.dataKind)
                    .padding(.vertical, 6)
                
                ZStack(alignment: .topLeading) {
                    HeatedLineChart(series: series)
                    
                    //LineChartFilterToggle()
                    //    .padding(.top, 6)
                }
                
            } else {
                ZStack {
                    Color.quaternarySystemFill
                    VStack {
                        Text ("No Data to display.\nPlease update the Dataset.")
                            .foregroundColor(.secondary)
                            .font(.headline)
                        
                        LineChartFilterToggle()
                    }
                }
                
            }
        }
        .transition(.opacity)
        .padding(.horizontal)
        .padding(.bottom, 12)
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

