//
//  LineChartWithDataKindPicker.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineChartWithDataKindPicker: View {
    @Binding var dataKind: DataKind
    
    var dataSet: DataSet
    
    let limitFirstBy: CGFloat
    
    var body: some View {
        let series = Array((dataSet.series[dataKind] ?? []).drop(while: { $0 < limitFirstBy }))
        
        return VStack(alignment: .leading, spacing: 8) {
            if series.isNotEmpty {
                DataKindPicker(selectedDataKind: $dataKind)
                
                Text(dataKind.rawValue)
                    .foregroundColor(dataKind.color)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 2)
                
                ZStack(alignment: .topLeading) {
                    HeatedLineChart(
                        xLabels: dataSet.chartSource(for: dataKind, limitFirstBy: limitFirstBy).xLabels,
                        series: dataSet.chartSource(for: dataKind, limitFirstBy: limitFirstBy).yValues
                    )
                    
                    ///  MARK: old version used special filter toggle button
                    ///  now filter is toggled by long press on yAxis
                    //    LineChartFilterToggle()
                    //        .padding(.top, 6)
                }
            } else {
                CallToUpdateView()
            }
        }
        .transition(.opacity)
        .padding(.bottom, 12)
    }
}

struct LineChartWithDataKindPickerTester: View {
    @State private var dataKind: DataKind = .confirmedDaily
    
    var body: some View {
        LineChartWithDataKindPicker(
            dataKind: $dataKind,
            dataSet: DataSet(name: "some country",
                             xLabels: [],
                             series: [.confirmedDaily: [200,300,500,700,1200,900, 1300, 800, 500]]),
            limitFirstBy: 400
        )
            .padding(.horizontal)
            .environmentObject(Store())
            .environmentObject(Settings())
    }
}

struct LineChartWithDataKindPicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            LineChartWithDataKindPickerTester()
        }
        .environment(\.colorScheme, .dark)
    }
}
