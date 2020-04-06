//
//  MultiCharts.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MultiCharts: Shape {
    var multiPoints: [[CGPoint]]
    
    /// «размеры» по всем сериям для определения общего масштаба
    var minX: CGFloat { multiPoints.flatMap { $0 }.map { $0.x }.min() ?? 0 }
    var maxX: CGFloat { multiPoints.flatMap { $0 }.map { $0.x }.max() ?? 1 }
    
    var minY: CGFloat { multiPoints.flatMap { $0 }.map { $0.y }.min() ?? 0 }
    var maxY: CGFloat { multiPoints.flatMap { $0 }.map { $0.y }.max() ?? 1 }

    
    private func normalized(points: [CGPoint], in rect: CGRect) -> [CGPoint] {
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
    
    func path(in rect: CGRect) -> Path {
        
        
        //  MARK НОРМАЛИЗОВАТЬ!!!!
        return Path { path in
            
            for i in multiPoints.indices {
                
                guard multiPoints[i].isNotEmpty else { return }
                
                var p = Path()
                p.move(to: normalized(points: multiPoints[i], in: rect)[0])
                
                for j in 1..<multiPoints[i].count {
                    p.addLine(to: normalized(points: multiPoints[i], in: rect)[j])
                }
                
                path.addPath(p)
                
            }
        }
    }
    
//    var body: some View {
//        let rect = CGSize(width: 300, height: 500)
//
//        return ZStack {
//            ForEach(multiPoints.indices) { ix in
//                self.path(points: self.normalized(points: self.multiPoints[ix],
//                                                  in: rect),
//                          in: rect)
//                    .stroke()
//            }
//        }
//    }
}

struct MultiCharts_Previews: PreviewProvider {
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 10),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 20, y: 40),
        CGPoint(x: 30, y: 30),
        CGPoint(x: 40, y: 60),
        CGPoint(x: 50, y: 140),
        CGPoint(x: 50, y: 180),
        CGPoint(x: 85, y: 200),
        CGPoint(x: 100, y: 190)
    ]
    
    static var previews: some View {
        MultiCharts(multiPoints: [points])
    }
}
