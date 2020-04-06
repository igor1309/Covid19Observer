//
//  LogisticCurve.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Numerics
import SwiftPI

func sigmoid<T: Real>(_ x: T) -> T {
    1 / (1 + .exp(-x))
}

func sigmoid(_ x: CGFloat) -> CGFloat {
    1 / (1 + CGFloat(.exp(Double(-x))))
}

extension CGFloat {
    
    /// `Probability Density Function`
    /// https://en.wikipedia.org/wiki/Logistic_distribution
    /// - Parameters:
    ///   - mu: μ, location parameter
    ///   - s: scale parameter
    func pdf(mu: CGFloat = 0, s: CGFloat = 1) -> CGFloat {
        
        if mu == 0 && s == 1 {
            let expMinusX = CGFloat(.exp(Double(-self)))
            /// When the location parameter μ is 0 and the scale parameter s is 1, then the probability density function of the logistic distribution is
            return expMinusX / ((1 + expMinusX) * (1 + expMinusX))
        } else {
            let exponent = CGFloat(.exp(Double(-(self - mu) / s)))
            return exponent / ( s * (1 + exponent) * (1 + exponent))
        }
        
    }
    
    var sigmoid: CGFloat { 1 / (1 + CGFloat(.exp(Double(-self)))) }
}

struct LogisticCurve: View {
    
    var points: [CGPoint] {
        var array = [CGPoint]()
        
        for x in stride(from: CGFloat(-10), through: 10, by: 0.1) {
            array.append(CGPoint(x: x, y: x.sigmoid))
        }
        
        return array
    }
    
    var pdfPoints: [CGPoint] {
        var array = [CGPoint]()
        
        for x in stride(from: CGFloat(-10), through: 10, by: 0.1) {
            array.append(CGPoint(x: x, y: x.pdf(mu: mu, s: s)))
        }
        
        return array
    }
    
    var pdfPoints0: [CGPoint] {
        var array = [CGPoint]()
        
        for x in stride(from: CGFloat(-10), through: 10, by: 0.1) {
            array.append(CGPoint(x: x, y: x.pdf()))
        }
        
        return array
    }
    
    /// «размеры» по всем сериям для определения общего масштаба графика
    /// - Parameter multiPoints: <#multiPoints description#>
    /// - Returns: <#description#>
    func chartBounds(multiPoints: [[CGPoint]]) -> CGRect {
        
        let minX = multiPoints.flatMap { $0 }.map { $0.x }.min() ?? 0
        let maxX = multiPoints.flatMap { $0 }.map { $0.x }.max() ?? 1
        
        let minY = multiPoints.flatMap { $0 }.map { $0.y }.min() ?? 0
        let maxY = multiPoints.flatMap { $0 }.map { $0.y }.max() ?? 1
        
        return CGRect(x: minX,
                      y: minY,
                      width: maxX,// - minX,
                      height: maxY)// - minY)
    }
    
    @State private var mu: CGFloat = 0
    @State private var s: CGFloat = 1
    
    var body: some View {
        let bounds = chartBounds(multiPoints: [pdfPoints, pdfPoints0])
        
        return VStack {
            HStack {
                Text("μ: \(mu, specifier: "%.2f")")
                    .font(.footnote)
                    .frame(width: 52)
                    .onTapGesture { self.mu = 0 }
                Slider(value: $mu, in: -10...10, step: 0.1)
            }
            HStack {
                Text("s: \(s, specifier: "%.2f")")
                    .font(.footnote)
                    .frame(width: 52)
                    .onTapGesture { self.s = 1 }
                Slider(value: $s, in: 0.3...6)
            }
            Divider()
            
            ZStack {
//                ChartGrid(xSteps: 10, ySteps: 10)
//                    .stroke(Color.systemGray,
//                            style: StrokeStyle(lineWidth: 0.5, dash: [12, 6]))
//                    .opacity(0.3)
                
                //                Chart(points: points)
                //                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                
//                MultiCharts(multiPoints: [pdfPoints0, pdfPoints])
//                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                
                LineChart(points: pdfPoints0, bounds: bounds)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                    .border(Color.pink)
                LineChart(points: pdfPoints, bounds: bounds)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                
                NearestPoint(points: [pdfPoints/*, pdfPoints0*/].flatMap { $0 }, is2D: false)
                
                Text("pdf0: \(CGFloat(0).pdf(), specifier: "%.2f")\npdf: \(CGFloat(0).pdf(mu: mu, s: s), specifier: "%.2f")")
                    .font(.subheadline)
                    .padding(8)
                    .roundedBackground()
                
//                Chart(points: pdfPoints0)
//                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
//
//                Chart(points: pdfPoints)
//                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                
                //            NearestPoint(points: points, is2D: false)
            }
        }
    }
}

struct LogisticCurve_Previews: PreviewProvider {
    static var previews: some View {
        LogisticCurve()
            //            .border(Color.pink.opacity(0.5))
            .padding()
    }
}

