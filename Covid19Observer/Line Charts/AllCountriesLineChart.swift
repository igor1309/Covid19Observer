//
//  AllCountriesLineChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct AllCountriesLineChart: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var numberOfGridLines = 0
    
    var series: [Int] {
        coronaStore.history.allCountriesTotals
    }
    
    var body: some View {
        VStack {
            
            Text("All Countries Confirmed Cases")
                .foregroundColor(.systemOrange)
                .font(.headline)
                .padding(.bottom, 6)
            
            ZStack(alignment: .topLeading) {
                HeatedLineChart(series: series.filtered(limit: settings.isLineChartFiltered ? settings.lineChartLimit : 0), numberOfGridLines: numberOfGridLines)
                
                ToolBarButton(systemName: "line.horizontal.3.decrease") {
                    self.settings.isLineChartFiltered.toggle()
                }
                .foregroundColor(settings.isLineChartFiltered ? .systemOrange : .systemBlue)
                .padding(.top, 6)
            }
        }
        .transition(.opacity)
        .padding()
            //        .padding(.bottom, 6)
            .onAppear {
                //            self.coronaStore.updateIfStoreIsOldOrEmpty()
                
                //  MARK: FINISH THIS
                //
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.numberOfGridLines = 10
                }
        }
    }
}

struct AllCountriesLineChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            AllCountriesLineChart()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
