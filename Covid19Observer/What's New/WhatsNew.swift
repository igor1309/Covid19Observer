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
            HStack {
                Text(store.currentSyncInfo.text)
                    .foregroundColor(store.currentSyncInfo.color)
                
                Text(store.currentSyncInfo.status)
                    .foregroundColor(.tertiary)
            }
            
            HStack {
                Text(store.historySyncInfo.text)
                    .foregroundColor(store.historySyncInfo.color)
                
                Text(store.historySyncInfo.status)
                    .foregroundColor(.tertiary)
            }
        }
        .padding(.horizontal)
        .font(.caption)
        .onReceive(
            Publishers.CombineLatest(
                timers.$thirtySeconds,
                store.$currentByCountry)
        ) { _ in
            self.text = self.store.currentSyncInfo.text
        }
    }
    
    var updateButtons: some View {
        HStack {
            Spacer()
            
            SpinningArrowsWithSubscriberButton(
                title: "Current",
                publisher: store.$currentIsUpdating.eraseToAnyPublisher()
            ) {
                self.store.fetchCurrent()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .roundedBackground(cornerRadius: 8, color: cardColor)
            
            Spacer()
            
            SpinningArrowsWithSubscriberButton(
                title: "History",
                publisher: store.$historyIsUpdating.eraseToAnyPublisher()
            ) {
                self.store.fetchHistory()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .roundedBackground(cornerRadius: 8, color: cardColor)
            
            Spacer()
        }
        .padding(.horizontal)
        .font(.subheadline)
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
                AllCountriesLineChartView()
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
                
                updateButtons
                    .padding(.bottom, 64)
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
