//
//  GraphGridShape.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct GraphGridShape: Shape {
    let series: [Int]
    let numberOfGridLines: Int
    
    /// normalized (0...1) array of data points
    private var normalized: [CGFloat] {
        if series.isEmpty {
            return []
        } else if series.max()! == 0 {
            return []
        } else {
            return series.map { CGFloat($0) / CGFloat(series.max()!) }
        }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { p in
            let step = rect.height / CGFloat(numberOfGridLines)
            
            for i in 0...numberOfGridLines {
                
                p.move(to: CGPoint(x: 0, y: rect.height - CGFloat(i) * step))
                p.addLine(to: CGPoint(x: rect.width, y: rect.height - CGFloat(i) * step))
                
                
            }
        }
    }
}
struct GraphGridShape_Previews: PreviewProvider {
    static var previews: some View {
        GraphGridShape(series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236],
                           numberOfGridLines: 10)
            .stroke(Color.systemGray3)
    }
}
