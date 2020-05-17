//
//  Home.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Home: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var store: Store
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
                CasesLineChartView(forAllCountries: false)
            } else {
                MapWithLineChartView()
            }
        }
    }
    
    var body: some View {
        TabView(selection: $settings.selectedTab) {
            
            WhatsNew()
                .tabItem {
                    Image(systemName: "rectangle.3.offgrid")
                    Text("Dashboard")
            }
            .tag(0)
            
            barChart
                .padding(.horizontal)
                .tabItem {
                    Image(systemName: "text.alignleft")
                    Text("World")
            }
            .tag(1)
            
            lineChart
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Country")
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
            DispatchQueue.main.async {
                self.store.updateIfOld()
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
