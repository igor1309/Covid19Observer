//
//  LineGraph.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// Simple Line Graph based on series of Int data points (Y values only)
struct LineGraph: Shape {
    let series: [Int]
    
    /// normalized (0...1) array of data points
    private var normalized: [CGFloat] {
        series.map { CGFloat($0) / CGFloat(series.max()!) }
    }
    
    func path(in rect: CGRect) -> Path {
        /// https://www.objc.io/blog/2020/03/16/swiftui-line-graph-animation/
        func point(_ ix: Int) -> CGPoint {
            let stepX = rect.width / CGFloat(series.count - 1)
            
            let x = (CGFloat(ix) + 0) * stepX
            
            let seriesMaxCGF = CGFloat(normalized.max()!)
            let stepY = rect.height / seriesMaxCGF
            let y = stepY * (1 - normalized[ix])
            
            return CGPoint(x: x, y: y)
        }
        
        return Path { p in
            guard series.isNotEmpty || series.max() ?? 0 > 0 else {
                return
            }
            
            p.move(to: point(0))
            
            for i in 1 ..< series.count {
                p.addLine(to: point(i))
            }
        }
        
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        //        LineGraph(series: [])
        //        LineGraph(series: [16,19,23,80])
        //        ZStack {
        //            LineGraph(series: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,5,18,28,43,61,95,139,245,388,593,978,1501,2336,2922,3513,4747,5823,6566,7161,8042,9000,10075,11364,12729,13938,14991])
        //            .stroke(Color.green, lineWidth: 2)
        LineGraph(series:
//            [1,0,4,5,7,11,1,15,16,19,23,24,24,25,27,28,28,28,28,28,29,30,31,31,104,204,433,602,
                           [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236])
            .stroke(Color.blue, lineWidth: 2)
            //    }
            .frame(height: 300)
            .border(Color.red.opacity(0.3))
            .padding()
    }
}
