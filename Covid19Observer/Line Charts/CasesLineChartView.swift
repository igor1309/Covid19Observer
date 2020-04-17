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
    
    @State private var appendCurrent = true
    
    var series: [Int] {
        switch settings.selectedDataKind {
        case .confirmedTotal:
            var series = coronaStore.confirmedHistory.series(for: coronaStore.selectedCountry)
            if appendCurrent {
                let last = coronaStore.selectedCountryOutbreak.confirmed
                series.append(last)
            }
            return series
        case .confirmedDaily:
        var series = coronaStore.confirmedHistory.dailyChange(for: coronaStore.selectedCountry)
            if appendCurrent {
                let last = coronaStore.selectedCountryOutbreak.confirmedCurrent
                series.append(last)
            }
            return series
        case .deathsTotal:
        var series = coronaStore.deathsHistory.series(for: coronaStore.selectedCountry)
            if appendCurrent {
                let last = coronaStore.selectedCountryOutbreak.deaths
                series.append(last)
            }
            return series
        case .deathsDaily:
        var series = coronaStore.deathsHistory.dailyChange(for: coronaStore.selectedCountry)
            if appendCurrent {
                let last = coronaStore.selectedCountryOutbreak.deathsCurrent
                series.append(last)
            }
            return series
        case .cfr:
            //  MARK: FIX THIS
            //
            return coronaStore.allCountriesCFR
        }
    }
    
    /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
    var body: some View {
        
        let isInSelected = settings.primeCountries.map { $0.name }.contains(coronaStore.selectedCountry)
        
        return VStack(alignment: .leading, spacing: 8) {
            
            PrimeCountryPicker(selection: $coronaStore.selectedCountry)
                .padding(.top)
            
            ZStack(alignment: .trailing) {
                HStack {
                    Button(action: {
                        self.showCountryPicker = true
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
                    .sheet(isPresented: $showCountryPicker) {
                        CountryPicker().environmentObject(self.coronaStore)
                    }
                    .layoutPriority(1)
                    
                    Spacer()
                }
                
                ToolBarButton(systemName: isInSelected ? "star.fill" : "star") {
                    if isInSelected {
                        let index = self.settings.primeCountries.firstIndex { $0.name == self.coronaStore.selectedCountry }!
                        self.settings.primeCountries.remove(at: index)
                    } else {
                        let iso2 = self.coronaStore.countriesWithIso2[self.coronaStore.selectedCountry]!
                        self.settings.primeCountries.append(Country(name: self.coronaStore.selectedCountry, iso2: iso2))
                    }
                }
                .foregroundColor(appendCurrent ? .systemOrange : .secondary)
                .font(.subheadline)
            }
            
            ZStack(alignment: .topTrailing) {
                Dashboard(outbreak: coronaStore.selectedCountryOutbreak, forAllCountries: false)
                
                ToolBarButton(systemName: appendCurrent ? "sun.max.fill" : "sun.min") {
                    self.appendCurrent.toggle()
                }
                .foregroundColor(appendCurrent ? .systemPurple : .secondary)
            }
            
            if series.isNotEmpty {
                
                DataKindPicker(selectedDataKind: $settings.selectedDataKind)
                    .padding(.vertical, 6)
                
                ZStack(alignment: .topLeading) {
                    HeatedLineChart(series: series.filtered(limit: settings.isLineChartFiltered ? settings.lineChartLimit : 0))//, steps: steps)
                    
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
            //                    //+ " " + coronaStore.confirmedHistory.rows[0].series.last
            //                )
            //                    .foregroundColor(.tertiary)
            //                    .font(.caption)
            //                    .padding(.bottom, 6)
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

