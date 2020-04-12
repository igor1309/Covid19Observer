//
//  WhatsNew.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct WhatsNew: View {
    let cardColor: Color = .tertiarySystemFill
    
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    var confirmedDeviations: [Deviation] { coronaStore.confirmedHistory.deviations }
    var deathsDeviations: [Deviation] { coronaStore.deathsHistory.deviations }
    
    var updated: some View {
        Text(coronaStore.timeSinceCasesUpdateStr == "0min"
            ? "Cases updated just now."
            : "Last update for Cases \(coronaStore.timeSinceCasesUpdateStr) ago.")
            + Text(" ")
            + Text(coronaStore.confirmedHistory.timeSinceUpdateStr == "0min"
                ? "History updated just now."
                : "Last update for History \(coronaStore.confirmedHistory.timeSinceUpdateStr) ago.")
    }
    
    
    @State private var listToShow: [Deviation] = []
    @State private var showCountryList = false
    @State private var kind: DataKind = .confirmedDaily
    
    var deviations: some View {
        
        func deviationRow(kind: DataKind, deviations: [Deviation], color: Color) -> some View {
            return VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.2")
                        .frame(width: 24)
                    Text(kind.id)
                    Spacer()
                    Text("(\(deviations.count.formattedGrouped))")
                        .font(.subheadline)
                }
                .foregroundColor(color)
                
                HStack {
                    Image(systemName: "map")
                        .frame(width: 24)
                    Text(deviations.map { $0.country }.joined(separator: ", "))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundColor(.secondary)
                .font(.footnote)
            }
            .contentShape(Rectangle())
            .padding(12)
            .roundedBackground(cornerRadius: 8, color: cardColor)
            .onTapGesture {
                self.showCountryList = true
                self.listToShow = deviations
                self.kind = kind
            }
        }
        
        let hasConfirmedDeviations = confirmedDeviations.count > 0
        let hasDeathsDeviations = deathsDeviations.count > 0
        
        return VStack(spacing: 8) {
            
            !(hasConfirmedDeviations || hasDeathsDeviations)
                ? nil
                : HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text("Significant Deviations")
                }
                .font(.subheadline)
            
            hasConfirmedDeviations
                ? deviationRow(kind: .confirmedDaily, deviations: confirmedDeviations, color: .systemYellow)
                : nil
            
            hasDeathsDeviations
                ? deviationRow(kind: .deathsDaily, deviations: deathsDeviations, color: .systemRed)
                : nil
            
            !(hasConfirmedDeviations || hasDeathsDeviations)
                ? Text("No significant changes in confirmed cases or deaths")
                    .foregroundColor(.systemGreen)
                    .font(.subheadline)
                : nil
            
            VStack(alignment: .leading) {
                hasConfirmedDeviations || hasDeathsDeviations
                    ? Group {
                        Text("7 days moving average deviations for more than 50%.")
                        Text("Based on history data, not current.\n")
                            .foregroundColor(.systemRed)
                        }
                    : nil
                updated
            }
            .padding(8)
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .padding()
    }
    
    
    @State private var showAllCountriesLineChart = false
    
    var world: some View {
        
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
        
        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "globe")
                Text("World")
            }
            .font(.subheadline)
            
            HStack {
                VStack(spacing: 12) {
                    item(name: "confirmed", valueStr: coronaStore.outbreak.confirmed, percent: nil)
                        .foregroundColor(.systemYellow)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .confirmedTotal
                            self.showAllCountriesLineChart = true
                    }
                    
                    item(name: "deaths", valueStr: coronaStore.outbreak.deaths, percent: nil)
                        .foregroundColor(.systemRed)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .deathsTotal
                            self.showAllCountriesLineChart = true
                    }
                }
                
                Spacer()
                VStack(spacing: 12) {
                    item(name: "new", valueStr: coronaStore.outbreak.confirmedNew, percent: "TBD%")
                        .foregroundColor(.systemOrange)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .confirmedDaily
                            self.showAllCountriesLineChart = true
                    }
                    
                    item(name: "new", valueStr: coronaStore.outbreak.deathsNew, percent: "TBD%")
                        .foregroundColor(.systemOrange)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .deathsDaily
                            self.showAllCountriesLineChart = true
                    }
                }
                
                Spacer()
                VStack(spacing: 12) {
                    item(name: "current", valueStr: coronaStore.outbreak.confirmedCurrent, percent: "TBD%")
                        .foregroundColor(.systemPurple)
                        .padding(8)
                    
                    item(name: "current", valueStr: coronaStore.outbreak.deathsCurrent, percent: "TBD%")
                        .foregroundColor(.systemPurple)
                        .padding(8)
                }
                
                Spacer()
                VStack(spacing: 12) {
                    item(name: "recovered", valueStr: coronaStore.outbreak.recovered, percent: "TBD%")
                        .foregroundColor(.systemGreen)
                        .padding(8)
                    
                    item(name: "CFR", valueStr: coronaStore.outbreak.cfr)
                        .foregroundColor(.systemTeal)
                        .padding(8)
                        .roundedBackground(cornerRadius: 8, color: cardColor)
                        .onTapGesture {
                            self.settings.selectedDataKind = .cfr
                            self.showAllCountriesLineChart = true
                    }
                }
            }
        }
        .padding()
    }
    
    
    @State private var showLineChart = false
    @State private var showTable = false
    
    var chartAndTableButtons: some View {
        HStack {
            Spacer()
            
            Button(action: {
                self.showLineChart = true
            }) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                    
                    Text("Charts".uppercased())
                }
                .padding()
                .roundedBackground(cornerRadius: 8, color: cardColor)
            }
            .sheet(isPresented: $showLineChart) {
                AllCountriesLineChart()
                    .environmentObject(self.coronaStore)
                    .environmentObject(self.settings)
            }
            
            Spacer()
            
            Button(action: {
                self.showTable = true
            }) {
                HStack {
                    Image(systemName: "table")
                    
                    Text("Table".uppercased())
                }
                .padding()
                .roundedBackground(cornerRadius: 8, color: cardColor)
            }
            .sheet(isPresented: $showTable) {
                CasesTableView()
                    .environmentObject(self.coronaStore)
                    .environmentObject(self.settings)
            }
            
            Spacer()
        }
        .font(.subheadline)
    }
    
    var  body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    Text("What's New")
                        .font(.title)
                        .padding(.top)
                    
                    world
                        .sheet(isPresented: $showAllCountriesLineChart) {
                            AllCountriesLineChart()
                                .environmentObject(self.coronaStore)
                                .environmentObject(self.settings)
                    }
                    
                    deviations
                        .sheet(isPresented: $showCountryList) {
                            CountryList(kind: self.kind, deviations: self.listToShow)
                                .environmentObject(self.coronaStore)
                                .environmentObject(self.settings)
                    }
                    
                    chartAndTableButtons
                        .padding(.vertical)
                }
            }
        }
    }
}

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            WhatsNew()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
