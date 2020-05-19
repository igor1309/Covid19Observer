//
//  Dashboard.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var showChart = false
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    var outbreak: Outbreak// { coronaStore.outbreak }
    var forAllCountries: Bool
    
    let defaultCardColor: Color = .tertiarySystemFill
    
    var body: some View {
        
        func item(name: String, valueStr: String, percent: String? = nil, color: Color, col: Int, isTappable: Bool = false) -> some View {
            
            let cardColor = forAllCountries
                ? isTappable ? defaultCardColor : .clear
                : .clear
            
            return VStack {
                Text(valueStr)
                    .font(.subheadline)
                Text(percent ?? " ")
                    .font(.caption)
                    .opacity(0.6)
                Text(name)
                    .font(.caption2)
            }
            .fixedSize()
            .foregroundColor(color)
            .contentShape(Rectangle())
            .widthPreference(column: col)
            .frame(width: self.columnWidths[col])
            .padding(forAllCountries ? 8 : 0)
            .roundedBackground(cornerRadius: 8, color: cardColor)
        }
        
        let vSpacing: CGFloat = forAllCountries ? 12 : 6
        let hSpacing: CGFloat = forAllCountries ? 12 : 18
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: hSpacing) {
                VStack(spacing: vSpacing) {
                    item(name: "confirmed", valueStr: outbreak.confirmedStr, percent: outbreak.confirmedToPopulationStr, color: CaseDataType.confirmed.color, col: 101, isTappable: true)
                        .onTapGesture {
                            self.settings.chartOptions.dataKind = .confirmedTotal
                            self.showChart = true
                    }
                    
                    
                    item(name: "deaths", valueStr: outbreak.deathsStr, percent: outbreak.deathsToPopulationStr, color: CaseDataType.deaths.color, col: 101, isTappable: true)
                        .onTapGesture {
                            self.settings.chartOptions.dataKind = .deathsTotal
                            self.showChart = true
                    }
                }
                
                VStack(spacing: vSpacing) {
                    item(name: "new", valueStr: outbreak.confirmedNewStr, percent: outbreak.confirmedNewToConfirmedStr, color: CaseDataType.new.color, col: 102, isTappable: true)
                        .onTapGesture {
                            self.settings.chartOptions.dataKind = .confirmedDaily
                            self.showChart = true
                    }
                    
                    item(name: "new", valueStr: outbreak.deathsNewStr, percent: outbreak.deathsNewToDeathsStr, color: CaseDataType.new.color, col: 102, isTappable: true)
                        .onTapGesture {
                            self.settings.chartOptions.dataKind = .deathsDaily
                            self.showChart = true
                    }
                }
                
                VStack(spacing: vSpacing) {
                    item(name: "current", valueStr: outbreak.confirmedCurrentStr, percent: outbreak.confirmedCurrentToConfirmedStr, color: CaseDataType.current.color, col: 103)
                    
                    item(name: "current", valueStr: outbreak.deathsCurrentStr, percent: outbreak.deathsCurrentToDeathsStr, color: CaseDataType.current.color, col: 103)
                }
                
                VStack(spacing: vSpacing) {
                    item(name: "recovered", valueStr: outbreak.recoveredStr, percent: outbreak.recoveredToConfirmedStr, color: .systemGreen, col: 105)
                    
                    item(name: "CFR", valueStr: outbreak.cfrStr, percent: outbreak.deathsPerMillionStr, color: CaseDataType.cfr.color, col: 104, isTappable: true)
                        .onTapGesture {
                            self.settings.chartOptions.dataKind = .cfr
                            self.showChart = true
                    }
                }
            }
        }
        .onPreferenceChange(WidthPreference.self) {
            self.columnWidths = $0
        }
        .padding(forAllCountries ? .all : .trailing)
        .sheet(isPresented: forAllCountries ? $showChart : .constant(false)) {
            AllCountriesLineChartView()
                .environmentObject(self.store)
                .environmentObject(self.settings)
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var coronaStore = CoronaStore()
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Dashboard(outbreak: coronaStore.outbreak, forAllCountries: true)
                
                Dashboard(outbreak: coronaStore.selectedCountryOutbreak, forAllCountries: false)
            }
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
