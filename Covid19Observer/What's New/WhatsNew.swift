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
    
    var updated: some View {
        let casesStr = coronaStore.timeSinceCasesUpdateStr == "0min"
            ? "Cases updated just now."
            : "Last update for Cases \(coronaStore.timeSinceCasesUpdateStr) ago."
        
        let casesColor: Color = coronaStore.timeSinceCasesUpdateStr == "0min"
            ? .systemGreen
            : .secondary
        
        let historyStr = coronaStore.confirmedHistory.timeSinceUpdateStr == "0min"
            ? "History updated just now."
            : "Last update for History \(coronaStore.confirmedHistory.timeSinceUpdateStr) ago."
        
        let historyColor: Color = coronaStore.confirmedHistory.timeSinceUpdateStr == "0min"
            ? .systemGreen
            : .secondary
        
        return VStack(alignment: .leading, spacing: 6) {
            Text(casesStr).foregroundColor(casesColor)
            Text(historyStr).foregroundColor(historyColor)
        }
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
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .roundedBackground(cornerRadius: 8, color: cardColor)
            }
            .sheet(isPresented: $showLineChart) {
                CasesLineChartView(forAllCountries: true)
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
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Text("What's New")
                    .font(.title)
                    .fontWeight(.light)
                    .padding(.top)
                
                HStack {
                    Image(systemName: "globe")
                    Text("World")
                        .font(.headline)
                }
                .font(.subheadline)
                
                Dashboard(outbreak: coronaStore.outbreak, forAllCountries: true)
                
                chartAndTableButtons
                    .padding(.vertical, 8)
                
                updated
                    .font(.caption)
                
                DeviationsView()
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
