//
//  CountryLineChartView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryLineChartSheet: View {
    var body: some View {
        CountryLineChartView()
            .padding(.top)
    }
}

struct CountryLineChartView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var showCountryPickerTable = false
    @State private var showTable = false
    
    var dataSet: DataSet { store.selectedCountryDataSet }
    
    var series: [CGFloat] {
        Array(
            store
                .series(for: settings.chartOptions.dataKind,
                        appendCurrent: settings.chartOptions.appendCurrent,
                        forAllCountries: false)
                .drop(while: { $0 < settings.chartOptions.lineChartLimit })
        )
    }
    
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
        Group {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            header
            
            LineChartWithDataKindPicker(dataKind: $settings.chartOptions.dataKind, dataSet: dataSet, limitFirstBy: settings.chartOptions.lineChartLimit)
        }
        .padding(.horizontal)
    }
}

struct CountryLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CountryLineChartView()
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
