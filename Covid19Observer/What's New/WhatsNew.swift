//
//  WhatsNew.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

struct WhatsNew: View {
    let cardColor: Color = .tertiarySystemFill
    
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @ObservedObject var timers = Timers()
    
    @State private var text = ""
    
    var updated: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button(action: {
                    self.store.fetchCurrent()
                }) {
                    Image(systemName: "arrow.2.circlepath")
                }
                .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 3) {
                    ZStack(alignment: .leading) {
                        Text(text)
                            .hidden()   //  трюк - скрытый вью заставялет по таймеру пересчитывать время после обновления
                        Text(store.sinceCurrentLastSync)
                            .foregroundColor(store.syncColor(for: store.currentByCountry.syncDate))
                    }
                    Text(store.syncStatusStr(status: store.syncStatus[.current(.byCountry), default: nil]))
                        .foregroundColor(.tertiary)
                }
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    self.store.fetchHistory()
                }) {
                    Image(systemName: "arrow.2.circlepath.circle")
                }
                .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.sinceHistoryLastSync)
                        .foregroundColor(store.syncColor(for: store.confirmedHistory.syncDate))
                    Text(store.syncStatusStr(status: store.syncStatus[.history(.confirmed), default: nil]))
                        .foregroundColor(.tertiary)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.caption)
        .onReceive(Publishers.CombineLatest(timers.$thirtySeconds, store.$currentByCountry)) { _ in
            self.text = self.store.sinceCurrentLastSync
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
                    .environmentObject(self.store)
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
                    .environmentObject(self.store)
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
                
                Dashboard(outbreak: store.outbreak, forAllCountries: true)
                
                chartAndTableButtons
                    .padding(.vertical, 8)
                
                
                updated
                
                VariationsView()
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
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
