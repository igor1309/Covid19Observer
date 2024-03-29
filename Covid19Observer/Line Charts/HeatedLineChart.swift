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
    @EnvironmentObject var settings: Settings
    
    let xLabels: [String]
    let series: [CGFloat]
    let lineWidth: CGFloat = 4
    let dotDiameter: CGFloat = 2
    
    //  MARK: FINISH THIS CHANGE TO FALSE FOR ANIMATION
    @State private var animated = false
    
    var points: [CGPoint] {
        guard series.isNotEmpty else { return [] }
        
        var pointSeries = [CGPoint]()
        for i in 0..<series.count {
            pointSeries.append(CGPoint(x: CGFloat(i),
                                       y: CGFloat(series[i])))
        }
        return pointSeries
    }
    
    var movingAvgPoints: [CGPoint] {
        guard points.isNotEmpty else { return [] }
        
        var maPoints = [CGPoint]()
        for i in 0..<points.count {
            let slice = points.prefix(i + 1).suffix(7)
            let avg = slice.reduce(CGFloat(0)) { $0 + $1.y } / CGFloat(slice.count)
            let point = CGPoint(x: points[i].x, y: avg)
            maPoints.append(point)
        }
        return maPoints
    }
    
    let heatGradient = LinearGradient(gradient: Gradient.temperetureGradient,
                                      startPoint: .bottom,
                                      endPoint: .top)
    
    var body: some View {
        let axisX = Axis(for: points.map { $0.x })
        let axisY = Axis(for: points.map { $0.y })
        let plotArea = CGPoint.plotAreaForAxises(axisX: axisX, axisY: axisY)
        
        return VStack {
            if series.isNotEmpty {
                HStack {
                    ZStack(alignment: .leading) {
                        
                        GridShape(steps: axisY.steps)
                            .stroke(Color.systemGray4, style: StrokeStyle(lineWidth: 0.5, dash: [10, 5]))
                        
                        
                        LineChart(points: movingAvgPoints, plotArea: plotArea)
                            .trim(to: animated ? 1 : 0)
                            .stroke(heatGradient,
                                    style: StrokeStyle(lineWidth: 3,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                        //      .opacity(0.75)
                        
                        LineChart(points: points, plotArea: plotArea)
                            .trim(to: animated ? 1 : 0)
                            .stroke(heatGradient,
                                    style: StrokeStyle(lineWidth: 0.5,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                            .opacity(0.3)
                        
                        DotChart(points: points, diameter: dotDiameter, plotArea: plotArea)
                            .trim(to: animated ? 1 : 0)
                            .stroke(heatGradient,
                                    style: StrokeStyle(lineWidth: dotDiameter,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                        
                        TapPointer(points: points, plotArea: plotArea, is2D: false)
                        
                        AxisY(axisY: axisY, labelColor: settings.chartOptions.isFiltered ? Color.orange : .secondary)
                            .opacity(0.6)
                            .onLongPressGesture {
                                //  MARK: ADD HAPTIC
                                withAnimation(.interactiveSpring()) {
                                    self.settings.chartOptions.isFiltered.toggle()
                                }
                        }
                    }
                    
                    //                    AxisY(axisY: axisY)
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
                CallToUpdateView()
            }
        }
    }
}

struct HeatedLineChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            HeatedLineChart(
                xLabels: [],
                series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236]
            )
                //            .border(Color.pink)
                .padding()
        }
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
