//
//  LineGraphGrid.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineGraphGridShape: Shape {
    let series: [Int]
    let numberOfGridLines: Int
    
    /// normalized (0...1) array of data points
    private var normalized: [CGFloat] {
        series.map { CGFloat($0) / CGFloat(series.max()!) }
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

struct LineGraphGrid: View {
    let series: [Int]
    let numberOfGridLines: Int
    
    /// normalized (0...1) array of data points
    private var normalized: [CGFloat] {
        series.map { CGFloat($0) / CGFloat(series.max()!) }
    }
    
    var body: some View {
        /// https://www.raywenderlich.com/6398124-swiftui-tutorial-for-ios-creating-charts
        GeometryReader { geo in
            ForEach(0..<self.numberOfGridLines + 1) { line in
                Group {
                    
                    Path { p in
                        let step = geo.size.height / CGFloat(self.numberOfGridLines)
                        
                        p.move(to: CGPoint(x: 0,
                                           y: geo.size.height - CGFloat(line) * step))
                        p.addLine(to: CGPoint(x: geo.size.width,
                                              y: geo.size.height - CGFloat(line) * step))
                    }
                    .stroke(Color.systemGray6)//,
//                            style: .init(lineWidth: 1, dash: [geo.size.height / 60, geo.size.height / 60], dashPhase: 0))
                    
//                    if line >= 0 {
                        Text("\(line * (self.series.max() ?? 0) / self.numberOfGridLines)")
                            .foregroundColor(line == 0 ? .clear : .secondary)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(
                                //                            x: geo.size.width - 50,
                                y: geo.size.height - CGFloat(line) * geo.size.height / CGFloat(self.numberOfGridLines) - 8)
                    }
                        
//                }
            }
        }
    }
}


struct LineGraphGrid_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LineGraphGrid(series:
                //            [1,0,4,5,7,11,1,15,16,19,23,24,24,25,27,28,28,28,28,28,29,30,31,31,104,204,433,602,
                [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236], numberOfGridLines: 10)
                .border(Color.red.opacity(0.3))
            
            LineGraphGridShape(series: [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236], numberOfGridLines: 10)
                .stroke(Color.blue, lineWidth: 1)
                //    }
                .frame(height: 300)
        }
        .padding()
    }
}
