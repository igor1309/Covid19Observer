//
//  HeatedLineChart.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct HeatedLineChart: View {
    let series: [Int]
    let lineWidth: CGFloat = 4
    
    @State private var animated = false
    
    var points: [CGPoint] {
        var pointSeries = [CGPoint]()
        
        guard series.isNotEmpty else { return [] }
        
        for i in 0..<series.count {
            pointSeries.append(CGPoint(x: CGFloat(i),
                                       y: CGFloat(series[i])))
        }
        
        return pointSeries
    }
    
    
    var body: some View {
        let axisX = Axis(for: points.map { $0.x })
        let axisY = Axis(for: points.map { $0.y })
        let plotArea = CGPoint.plotAreaForAxises(axisX: axisX, axisY: axisY)
        
        return VStack {
            if series.isNotEmpty {
                HStack {
                    ZStack {
                        
                        GridShape(steps: axisY.steps)
                            .stroke(Color.systemGray4, style: StrokeStyle(lineWidth: 0.5, dash: [10, 5]))
                        
                        
                        LineChart(points: points, plotArea: plotArea)
                            .trim(to: animated ? 1 : 0)
                            .stroke(LinearGradient(gradient: Gradient.temperetureGradient,
                                                   startPoint: .bottom,
                                                   endPoint: .top),
                                    style: StrokeStyle(lineWidth: 0.5,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                        
                        DotChart(points: points, plotArea: plotArea)
                            .trim(to: animated ? 1 : 0)
                            .stroke(LinearGradient(gradient: Gradient.temperetureGradient,
                                                   startPoint: .bottom,
                                                   endPoint: .top),
                                    style: StrokeStyle(lineWidth: lineWidth,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                        
                        TapPointer(points: points, plotArea: plotArea, is2D: false)
                    }
                    
                    AxisY(axisY: axisY)
                }
                .padding(lineWidth / 2)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            self.animated = true
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Text("No Data")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            }
        }
    }
}

struct HeatedLineChart_Previews: PreviewProvider {
    static var previews: some View {
        HeatedLineChart(series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236])
            //            .border(Color.pink)
            .padding()
    }
}
