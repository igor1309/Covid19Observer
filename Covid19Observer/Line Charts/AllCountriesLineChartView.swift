//
//  AllCountriesLineChartView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct AllCountriesLineChartView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    var series: [CGFloat] {
        Array(
            store
                .series(for: settings.chartOptions.dataKind,
                        appendCurrent: settings.chartOptions.appendCurrent,
                        forAllCountries: true)
                .drop(while: { $0 < settings.chartOptions.lineChartLimit })
        )
    }
    
    var header: some View {
        Group {
            Text("All Countries \(settings.chartOptions.dataKind.id)")
                .foregroundColor(.systemOrange)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 6)
            
            settings.chartOptions.dataKind == .cfr
                ? Text("TO BE DONE")
                    .foregroundColor(.red)
                    .font(.title)
                : nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            header
            
            LineChartWithDataKindPicker(
                dataKind: $settings.chartOptions.dataKind,
                dataSet: DataSet(name: "some country",
                                 xLabels: [],
                                 series: [settings.chartOptions.dataKind: series]
                ),
                limitFirstBy: settings.chartOptions.lineChartLimit
            )
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

struct AllCountriesLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            AllCountriesLineChartView()
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
