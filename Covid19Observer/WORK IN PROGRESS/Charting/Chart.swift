//
//  Chart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 05.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Chart: Shape {
    let points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        
        var normalized: [CGPoint] {
            let minX = points.map { $0.x }.min() ?? 0
            let maxX = points.map { $0.x }.max() ?? 1
            
            let minY = points.map { $0.y }.min() ?? 0
            let maxY = points.map { $0.y }.max() ?? 1
            
            /// Перевод обычной сетки координат, задаваемой серией данных, в rect. Прим: это не нормализация на <0...1>(!!!), а нормализация на размеры rect.
            /// https://en.wikipedia.org/wiki/Feature_scaling
            /// - Parameter point: координаты точки из серии
            /// - Returns: координаты в пространстве, заданном rect
            func normalizedPoint(_ point: CGPoint) -> CGPoint {
                let x = (point.x - minX) / (maxX - minX) * rect.width
                let y = (1 - (point.y - minY) / (maxY - minY)) * rect.height
                return CGPoint(x: x, y: y)
            }
            
            return points.map { normalizedPoint($0) }
        }
        
        return Path { p in
            guard points.isNotEmpty else { return }
            
            p.move(to: normalized[0])
            
            for i in 1..<normalized.count {
                p.addLine(to: normalized[i])
            }
        }
    }
}

struct Chart_Previews: PreviewProvider {
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 10),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 20, y: 40),
        CGPoint(x: 30, y: 30),
        //        CGPoint(x: 40, y: 60),
        //        CGPoint(x: 50, y: 140),
        CGPoint(x: 50, y: 180),
        CGPoint(x: 85, y: 200),
        CGPoint(x: 100, y: 190)
    ]
    static var previews: some View {
        Chart(points: points)
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineJoin: .round))
            .border(Color.pink.opacity(0.5))
            .padding()
    }
}
