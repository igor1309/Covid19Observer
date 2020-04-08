//
//  DotChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 07.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct DotChart: Shape {
    var points: [CGPoint]
    
    let minX, maxX, minY, maxY: CGFloat
    
    init(points: [CGPoint], plotArea: CGRect? = nil) {
        self.points = points
        if plotArea == nil {
            self.minX = points.map { $0.x }.min() ?? 0
            self.minY = points.map { $0.y }.min() ?? 0
            self.maxX = points.map { $0.x }.max() ?? 1
            self.maxY = points.map { $0.y }.max() ?? 1
        } else {
            self.minX = plotArea!.minX
            self.minY = plotArea!.minY
            self.maxX = plotArea!.width
            self.maxY = plotArea!.height
        }
    }
    
    func path(in rect: CGRect) -> Path {
        
        /// Перевод обычной сетки координат, задаваемой серией данных, в rect. Прим: это не нормализация на <0...1>(!!!), а нормализация на размеры rect.
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// - Parameter point: координаты точки из серии
        /// - Returns: координаты в пространстве, заданном `rect`
        func normalized(_ point: CGPoint) -> CGPoint {
            let x = (point.x - minX) / (maxX - minX) * rect.width
            let y = (1 - (point.y - minY) / (maxY - minY)) * rect.height
            return CGPoint(x: x, y: y)
        }
        
        func ellipseRect(for point: CGPoint) -> CGRect {
            let radius: CGFloat = 2
            
            return CGRect(x: point.x - radius,
                          y: point.y - radius,
                          width: 2 * radius,
                          height: 2 * radius)
        }
        
        return Path { p in
            guard points.isNotEmpty else { return }
            
            for i in 1..<points.count {
                p.addEllipse(in: ellipseRect(for: normalized(points[i])))
            }
        }
    }
}

struct DotChart_Previews: PreviewProvider {
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 10),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 20, y: 40),
        CGPoint(x: 30, y: 30),
        //        CGPoint(x: 40, y: 60),
        //        CGPoint(x: 50, y: 140),
        CGPoint(x: 50, y: 180),
        CGPoint(x: 80, y: 200),
        CGPoint(x: 85, y: 200),
        CGPoint(x: 100, y: 190)
    ]
    
    static let lineWidth: CGFloat = 4
    
    static var previews: some View {
        VStack {
            ZStack {
                DotChart(points: points,
                         plotArea: CGRect(x: 0, y: 0, width: 200, height: 300))
//                plotArea: CGPoint.plotAreaForPoints(points))
                    .stroke(LinearGradient(gradient: Gradient.temperetureGradient,
                                   startPoint: .bottom,
                                   endPoint: .top),
                    style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round,
                                       lineJoin: .round))
                    .border(Color.pink)
                
                TapPointer(points: points,
                           plotArea: CGRect(x: 0, y: 0, width: 200, height: 300),
                           is2D: false)
            }
            
            HStack {
                DotChart(points: points, plotArea: nil)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                    .border(Color.pink)
                DotChart(points: points, plotArea: nil)
                    .fill(Color.purple)
                    .border(Color.pink)
            }
        }
        .padding()
    }
}
