//
//  LineChartView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineChartView: View {
    let rangeTime: Range<Int>
    let countryRow: CountryRow
    /// если rangeY не задан, то границы графика по оси Y определяются по значениям
    let rangeY: Range<Int>?
    
    private var minY: Int { rangeY == nil
        ? countryRow.series[rangeTime].min()!
        : rangeY!.lowerBound
    }
    private var maxY: Int { rangeY == nil
        ? countryRow.series[rangeTime].max()!
        : rangeY!.upperBound
    }
    
    var body: some View {
        LineChartShape(rangeTime: rangeTime,
                       countryRow: countryRow,
                       lowerY: CGFloat(minY),
                       upperY: CGFloat(maxY))
            .stroke(LinearGradient(gradient: Gradient.temperetureGradient,
                                   startPoint: .bottom,
                                   endPoint: .top),
                    style: StrokeStyle(lineWidth: 3,
                                       lineCap: .round,
                                       lineJoin: .round))
            .animation(.linear(duration: 1))
    }
}

struct LineChartView_Previews: PreviewProvider {
    static let series = [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236]
    
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Group {
                LineChartView(rangeTime: 0..<series.count,
                              countryRow: CountryRow(provinceState: "", countryRegion: "Russia", points: [:], series: series, isHidden: false), rangeY: 0..<15_000)
                LineChartView(rangeTime: 0..<series.count,
                              countryRow: CountryRow(provinceState: "", countryRegion: "Russia", points: [:], series: series, isHidden: false), rangeY: nil)

            }
            .padding()
        }
        .border(Color.pink.opacity(0.3))
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
