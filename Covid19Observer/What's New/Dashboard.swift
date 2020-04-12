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
    
    var body: some View {
        
        func item(name: String, valueStr: String, percent: String? = nil) -> some View {
            VStack {
                Text(valueStr)
                    .font(.subheadline)
                Text(percent ?? " ")
                    .font(.caption)
                    .opacity(0.6)
                Text(name)
                    .font(.caption2)
            }
            .contentShape(Rectangle())
        }
        
        var outbreak: Outbreak { coronaStore.outbreak }
        
        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "globe")
                Text("World")
                Text(coronaStore.populationOf(country: nil).formattedGrouped)
                    .foregroundColor(.tertiary)
                    .font(.footnote)
            }
            .font(.subheadline)
            
            HStack(spacing: 8) {
                VStack(spacing: 12) {
                    item(name: "confirmed", valueStr: outbreak.confirmed, percent: nil)
                        .foregroundColor(CaseDataType.confirmed.color)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .confirmedTotal
                            self.showAllCountriesLineChart = true
                    }
                    
                    item(name: "deaths", valueStr: outbreak.deaths, percent: nil)
                        .foregroundColor(CaseDataType.deaths.color)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .deathsTotal
                            self.showAllCountriesLineChart = true
                    }
                }
                
                Spacer()
                VStack(spacing: 12) {
                    item(name: "new", valueStr: outbreak.confirmedNew, percent: "TBD%")
                        .foregroundColor(CaseDataType.new.color)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .confirmedDaily
                            self.showAllCountriesLineChart = true
                    }
                    
                    item(name: "new", valueStr: outbreak.deathsNew, percent: "TBD%")
                        .foregroundColor(CaseDataType.new.color)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .deathsDaily
                            self.showAllCountriesLineChart = true
                    }
                }
                
                Spacer()
                VStack(spacing: 12) {
                    item(name: "current", valueStr: outbreak.confirmedCurrent, percent: "TBD%")
                        .foregroundColor(CaseDataType.current.color)
                        .padding(8)
                    
                    item(name: "current", valueStr: outbreak.deathsCurrent, percent: "TBD%")
                        .foregroundColor(CaseDataType.current.color)
                        .padding(8)
                }
                
                Spacer()
                VStack(spacing: 12) {
                    item(name: "d per 1m", valueStr: outbreak.deathsPerMillion, percent: "TBD%")
                        .foregroundColor(CaseDataType.cfr.color)
                        .padding(8)
                    
                    item(name: "CFR", valueStr: outbreak.cfr)
                        .foregroundColor(CaseDataType.cfr.color)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .cfr
                            self.showAllCountriesLineChart = true
                    }
                }
            }
            
            item(name: "recovered", valueStr: outbreak.recovered, percent: "TBD%")
            .foregroundColor(.systemGreen)
            .padding(8)
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
