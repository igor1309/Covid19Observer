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
    
    init(points: [CGPoint], bounds: CGRect? = nil) {
        self.points = points
        if bounds == nil {
            self.minX = points.map { $0.x }.min() ?? 0
            self.minY = points.map { $0.y }.min() ?? 0
            self.maxX = points.map { $0.x }.max() ?? 1
            self.maxY = points.map { $0.y }.max() ?? 1
        } else {
            self.minX = bounds!.minX
            self.minY = bounds!.minY
            self.maxX = bounds!.width
            self.maxY = bounds!.height
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
    
    static let temperetureGradient = Gradient(colors: [
        .purple,
        Color(red: 0, green: 0, blue: 139.0/255.0),
        .blue,
        Color(red: 30.0/255.0, green: 144.0/255.0, blue: 1.0),
        Color(red: 0, green: 191/255.0, blue: 1.0),
        Color(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0),
        .green,
        .yellow,
        .orange,
        Color(red: 1.0, green: 140.0/255.0, blue: 0.0),
        .red,
        Color(red: 139.0/255.0, green: 0.0, blue: 0.0)
    ])
    
    static let lineWidth: CGFloat = 4
    static var previews: some View {
        VStack {
            DotChart(points: points, bounds: CGRect(x: 0, y: 0, width: 100, height: 220))
                .stroke(LinearGradient(gradient: temperetureGradient,
                               startPoint: .bottom,
                               endPoint: .top),
                style: StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round,
                                   lineJoin: .round))
                .border(Color.pink)
            
            DotChart(points: points, bounds: nil)
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                .border(Color.pink)
        }
        .padding()
    }
}
