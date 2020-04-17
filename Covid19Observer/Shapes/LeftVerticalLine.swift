//
//  LeftVerticalLine.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 04.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// Draws a vertical line at the left side of the provided rect
struct LeftVerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addLines([
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.minX, y: rect.maxY)
        ])
        return p
    }
}

struct LeftVerticalLine_Previews: PreviewProvider {
    static var previews: some View {
        LeftVerticalLine()
        .stroke()
            .frame(width: 300, height: 300)
    }
}
