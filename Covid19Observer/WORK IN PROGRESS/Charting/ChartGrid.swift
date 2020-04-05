//
//  ChartGrid.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 05.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct ChartGrid: Shape {
    let xSteps: Int
    let ySteps: Int
    
    func path(in rect: CGRect) -> Path {
        let xStep = rect.width / CGFloat(xSteps)
        let yStep = rect.height / CGFloat(ySteps)
        
        return Path { p in
            for i in 0...xSteps {
                p.move(to: CGPoint(x: xStep * CGFloat(i), y: 0))
                p.addLine(to: CGPoint(x: xStep * CGFloat(i), y: rect.height))
            }
            
            for i in 0...ySteps {
                p.move(to: CGPoint(x: 0, y: yStep * CGFloat(i)))
                p.addLine(to: CGPoint(x: rect.width, y: yStep * CGFloat(i)))
            }
        }
    }
}

struct ChartGrid_Previews: PreviewProvider {
    static var previews: some View {
        ChartGrid(xSteps: 10, ySteps: 20)
            .stroke(Color.systemGray3, style: StrokeStyle(lineWidth: 0.5, dash: [10, 5]))
        .padding()
    }
}
