//
//  ContentView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        TabView(selection: $settings.selectedTab) {
            CasesChartView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Chart")
            }
            .tag(0)
            
            CasesOnMapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
            }
            .tag(1)
            
            CasesLineChartView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("History")
            }
            .tag(2)
//            CasesTableView()
//                .tabItem {
//                    Image(systemName: "table")
//                    Text("Table")
//            }
//            .tag(2)
            
            DoublingTimeView()
                .tabItem {
                    Image(systemName: "rectangle.on.rectangle.angled")
                    Text("Doubling")
            }
            .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
            .tag(4)
        }
        .onAppear {
            self.coronaStore.updateIfStoreIsOldOrEmpty()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CoronaStore())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
