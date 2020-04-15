//
//  LineChartGroup.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

/// объединение диапазонов
/// https://bestkora.com/IosDeveloper/swiftui-dlya-konkursnogo-zadaniya-telegram-10-24-marta-2019-goda/
/// - Parameter ranges: диапазоны
/// - Returns: объединенный дмапазон
func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Int> where C.Element == Range<Int> {
    guard ranges.isNotEmpty else { return 0..<0 }
    let low = ranges.lazy.map { $0.lowerBound }.min()!
    let high = ranges.lazy.map { $0.upperBound }.max()!
    return low..<high
}

struct LineChartGroup: View {
    var countryRows: [CountryRow]
    var rangeTime: Range<Int>
    
    private var rangeY: Range<Int> {
        let rangeY = rangeOfRanges(
            countryRows
                .filter { $0.isHidden }
                .map { $0.series[rangeTime].min()!..<$0.series[rangeTime].max()! }
        )
        return rangeY == 0..<0 ? 0..<1 : rangeY
    }
    
    var body: some View {
        ZStack {
            ForEach(countryRows, id: \.id) { countryRow in
                LineChartView(rangeTime: self.rangeTime,
                              countryRow: countryRow,
                              rangeY: self.rangeY)
                    .transition(.move(edge: .top))
            }
        }
            /// use `Metal` for complex drawings
            .drawingGroup()
    }
}

struct LineChartGroup_Previews: PreviewProvider {
    static var previews: some View {
        LineChartGroup(countryRows: [], rangeTime: 0..<100)
    }
}
