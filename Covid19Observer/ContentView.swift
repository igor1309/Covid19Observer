//
//  ContentView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    var barChart: some View {
        Group {
            if sizeClass == .compact {
                CasesChartView()
            } else {
                CasesChartsIPad()
            }
        }
    }
    
    var lineChart: some View {
        Group {
            if sizeClass == .compact {
                CasesLineChartView()
            } else {
                MapWithLineChartView()
            }
        }
    }
    
    var body: some View {
        TabView(selection: $settings.selectedTab) {
            
            WhatsNew()
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("New")
            }
            .tag(0)
            
            barChart
                .padding()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Chart")
            }
            .tag(1)
            
            lineChart
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("History")
            }
            .tag(2)
            
            CasesOnMapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
            }
            .tag(3)
            
            //            CasesTableView()
            //                .tabItem {
            //                    Image(systemName: "table")
            //                    Text("Table")
            //            }
            //            .tag(2)
            
//            DoublingTimeView()
//                .tabItem {
//                    Image(systemName: "rectangle.on.rectangle.angled")
//                    Text("Doubling")
//            }
//            .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
            .tag(4)
        }
        .onAppear {
            self.coronaStore.updateEmptyOrOldStore()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.coronaStore.updateEmptyOrOldStore()
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
