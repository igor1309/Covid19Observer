//
//  Dashboard.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    let cardColor: Color = .tertiarySystemFill
    
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var showAllCountriesLineChart = false
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    var body: some View {
        
        func item(name: String, valueStr: String, percent: String? = nil, color: Color, col: Int, isTappable: Bool = false) -> some View {
            
            VStack {
                Text(valueStr)
                    .font(.subheadline)
                //                    .fixedSize()
                Text(percent ?? " ")
                    .font(.caption)
                    //                    .fixedSize()
                    .opacity(0.6)
                Text(name)
                    .font(.caption2)
                //                    .fixedSize()
            }
            .fixedSize()
            .foregroundColor(color)
            .contentShape(Rectangle())
            .widthPreference(column: col)
            .frame(width: self.columnWidths[col])
            .padding(8)
            .roundedBackground(cornerRadius: 8, color: isTappable ? cardColor : .clear)
        }
        
        var outbreak: Outbreak { coronaStore.outbreak }
        
        let worldPopulation = Double(coronaStore.populationOf(country: nil))
        
        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "globe")
                Text("World")
                Text(worldPopulation.formattedGrouped)
                    .foregroundColor(.tertiary)
                    .font(.footnote)
            }
            .font(.subheadline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    VStack(spacing: 12) {
                        item(name: "confirmed", valueStr: outbreak.confirmedStr, percent: outbreak.confirmedToPopulationStr, color: CaseDataType.confirmed.color, col: 101, isTappable: true)
                            .onTapGesture {
                                self.settings.selectedDataKind = .confirmedTotal
                                self.showAllCountriesLineChart = true
                        }
                        
                        
                        item(name: "deaths", valueStr: outbreak.deathsStr, percent: outbreak.deathsToPopulationStr, color: CaseDataType.deaths.color, col: 101, isTappable: true)
                            .onTapGesture {
                                self.settings.selectedDataKind = .deathsTotal
                                self.showAllCountriesLineChart = true
                        }
                    }
                    
                    VStack(spacing: 12) {
                        item(name: "new", valueStr: outbreak.confirmedNewStr, percent: outbreak.confirmedNewToConfirmedStr, color: CaseDataType.new.color, col: 102, isTappable: true)
                            .onTapGesture {
                                self.settings.selectedDataKind = .confirmedDaily
                                self.showAllCountriesLineChart = true
                        }
                        
                        item(name: "new", valueStr: outbreak.deathsNewStr, percent: outbreak.deathsNewToDeathsStr, color: CaseDataType.new.color, col: 102, isTappable: true)
                            .onTapGesture {
                                self.settings.selectedDataKind = .deathsDaily
                                self.showAllCountriesLineChart = true
                        }
                    }
                    
                    VStack(spacing: 12) {
                        item(name: "current", valueStr: outbreak.confirmedCurrentStr, percent: outbreak.confirmedCurrentToConfirmedStr, color: CaseDataType.current.color, col: 103)
                        
                        item(name: "current", valueStr: outbreak.deathsCurrentStr, percent: outbreak.deathsCurrentToDeathsStr, color: CaseDataType.current.color, col: 103)
                    }
                    
                    VStack(spacing: 12) {
                        item(name: "recovered", valueStr: outbreak.recoveredStr, percent: outbreak.recoveredToConfirmedStr, color: .systemGreen, col: 105)
                        
                        item(name: "CFR", valueStr: outbreak.cfrStr, percent: outbreak.deathsPerMillionStr, color: CaseDataType.cfr.color, col: 104, isTappable: true)
                            .onTapGesture {
                                self.settings.selectedDataKind = .cfr
                                self.showAllCountriesLineChart = true
                        }
                    }
                }
            }
            .onPreferenceChange(WidthPreference.self) {
                self.columnWidths = $0
            }
        }
        .padding()
        .sheet(isPresented: $showAllCountriesLineChart) {
            AllCountriesLineChart()
                .environmentObject(self.coronaStore)
                .environmentObject(self.settings)
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Dashboard()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
