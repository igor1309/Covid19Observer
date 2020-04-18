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
    
//    @State private var steps = 0
    
    var series: [Int] {
        switch settings.chartOptions.dataKind {
        case .confirmedTotal:
            return coronaStore.confirmedHistory.allCountriesTotals
        case .confirmedDaily:
            return coronaStore.confirmedHistory.allCountriesDailyChange
        case .deathsTotal:
            return coronaStore.deathsHistory.allCountriesTotals
        case .deathsDaily:
            return coronaStore.deathsHistory.allCountriesDailyChange
        case .cfr:
            return coronaStore.allCountriesCFR
        }
    }
    
    var body: some View {
        VStack {
            
            Text("All Countries \(settings.chartOptions.dataKind.id)")
                .foregroundColor(.systemOrange)
                .font(.headline)
                .padding(.bottom, 6)
            
            DataKindPicker(selectedDataKind: $settings.chartOptions.dataKind)
            
            settings.chartOptions.dataKind == .cfr
                ? Text("TO BE DONE")
                    .foregroundColor(.red)
                    .font(.title)
                : nil
            
            ZStack(alignment: .topLeading) {
                HeatedLineChart(series: series.filtered(limit: settings.chartOptions.isFiltered ? settings.chartOptions.confirmedLimit : 0))//, steps: steps)
                
                ToolBarButton(systemName: "line.horizontal.3.decrease") {
                    self.settings.chartOptions.isFiltered.toggle()
                }
                .foregroundColor(settings.chartOptions.isFiltered ? .systemOrange : .systemBlue)
                .padding(.top, 6)
            }
        }
        .transition(.opacity)
        .padding()
            //        .padding(.bottom, 6)
//            .onAppear {
//                //            self.coronaStore.updateEmptyOrOldStore()
//
//                //  MARK: FINISH THIS
//                //
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.steps = 10
//                }
//        }
    }
}

struct AllCountriesLineChart_Previews: PreviewProvider {
    @State static var selectedDataKind: DataKind = .confirmedTotal
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
