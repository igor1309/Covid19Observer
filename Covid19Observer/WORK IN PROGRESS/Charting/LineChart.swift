//
//  LineChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineChart: Shape {
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
        
        return Path { p in
            guard points.isNotEmpty else { return }
            
            p.move(to: normalized(points[0]))
            for i in 1..<points.count {
                p.addLine(to: normalized(points[i]))
            }
        }
    }
}

struct LineChart_Previews: PreviewProvider {
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
    
    static var previews: some View {
        VStack {
            LineChart(points: points, plotArea: CGRect(x: 0, y: 0, width: 100, height: 220))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .border(Color.pink)
            
            LineChart(points: points, plotArea: nil)
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .border(Color.pink)
        }
        .padding()
    }
}
