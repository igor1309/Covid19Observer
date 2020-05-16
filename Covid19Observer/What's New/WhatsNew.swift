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
            HStack(spacing: 16) {
                SpinningArrowsWithSubscriberButton(
                    publisher: store.$currentIsUpdating.eraseToAnyPublisher()
                ) {
                    self.store.fetchCurrent()
                }
                
                HStack {
                    Text(store.currentByCountrySyncStatus.rawValue)
                        .foregroundColor(.tertiary)
                    
                    if store.currentByCountrySyncStatusIsStable {
                        Text(store.sinceCurrentLastSync)
                            .foregroundColor(store.syncColor(for: store.currentByCountry.syncDate))
                    }
                }
            }
            
            HStack(spacing: 16) {
                SpinningArrowsWithSubscriberButton(
                    publisher: store.$historyIsUpdating.eraseToAnyPublisher()
                ) {
                    self.store.fetchHistory()
                }
                
                HStack {
                    Text(store.confirmedHistorySyncStatus.rawValue)
                        .foregroundColor(.tertiary)
                    
                    if store.confirmedHistorySyncStatusIsStable {
                        //                    if store.confirmedHistoryIsInStableStatus {
                        Text(store.sinceHistoryLastSync)
                            .foregroundColor(store.syncColor(for: store.confirmedHistory.syncDate))
                    }
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
