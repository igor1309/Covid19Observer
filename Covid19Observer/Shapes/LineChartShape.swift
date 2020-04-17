//
//  LineChartShape.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineChartShape: Shape {
    let rangeTime: Range<Int>
    let countryRow: CountryRow
    var lowerY: CGFloat
    var upperY: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(lowerY, upperY)
        }
        set {
            lowerY = newValue.first
            upperY = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let scaleY: CGFloat = lowerY == upperY
                ? 1
                : rect.height / CGFloat(upperY - lowerY)
            let origin = CGPoint(x: 0, y: rect.height)
            let stepX = width / CGFloat(rangeTime.distance - 1)
            
            path.addLines(
                Array(rangeTime.lowerBound..<rangeTime.upperBound)
                    .map {
                        CGPoint(
                            x: origin.x + CGFloat($0 - rangeTime.lowerBound) * stepX,
                            y: origin.y - (CGFloat(countryRow.series[$0]) - lowerY) * scaleY
                        )
            })
            
        }
    }
}
