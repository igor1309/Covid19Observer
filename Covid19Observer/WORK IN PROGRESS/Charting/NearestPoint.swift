//
//  NearestPoint.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 05.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct NearestPoint: View {
    let points: [CGPoint]
    @State private var size: CGSize = .zero
    
    @State private var currentOffset: CGSize = .zero
    @State private var offset: CGSize = .zero
    @State private var showCrosshair = false
    
    /// Translates offset in iOS flipped-coordinate space to normal (as in Core Graphics) coordinate.
    /// In the default Core Graphics coordinate space, the origin is located in the lower-left corner of the rectangle and the rectangle extends towards the upper-right corner.
    /// - Parameter offset: offset (CGSize)
    /// - Returns: CGPoint in nornal coordinate space
    func cgCoordinate(for offset: CGSize) -> CGPoint {
        let maxX = points.map { $0.x }.max() ?? 1
        let maxY = points.map { $0.y }.max() ?? 1
        
        return CGPoint(x: (offset.width + size.width / 2) * maxX / size.width,
                       y: (size.height / 2 - offset.height) * maxY / size.height)
    }
    
    /// The opposite to cgCoordinate function: returns ofset in iOS coordinate space from CGPoint.
    /// - Parameter point: CGPoint in iOS coordinate space to translate to offset
    /// - Returns: offset size
    func offsetFromCGCoordinate(for point: CGPoint) -> CGSize {
        let maxX = points.map { $0.x }.max() ?? 1
        let maxY = points.map { $0.y }.max() ?? 1
        
        return CGSize(width: point.x / maxX * size.width - size.width / 2,
                      height: (1 - point.y / maxY) * size.height - size.height / 2)
    }
    
    var crosshair: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .opacity(0.5)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading) {
                Text("x: \(Int(offset.width)) : \(Int(cgCoordinate(for: currentOffset).x))")
                Text("y: \(Int(offset.height)) : \(Int(cgCoordinate(for: currentOffset).y))")
            }
            .font(.caption)
        }
        .padding(8)
            //        .background(Color.secondarySystemFill)
            //        .clipShape(RoundedRectangle(cornerRadius: 8))
            .offset(currentOffset)
    }
    
    var nearestPoint: some View {
        let nearestPointOffset = offsetFromCGCoordinate(for: nearestPoint(target: cgCoordinate(for: currentOffset), points: points))
        
        return ZStack {
            Circle()
                .fill(Color.orange)
                .opacity(0.5)
                .frame(width: 16, height: 16)
                .offset(nearestPointOffset)
            
            VStack {
                Text("x: \(Int(nearestPoint(target: cgCoordinate(for: currentOffset), points: points).x))")
                Text("y: \(Int(nearestPoint(target: cgCoordinate(for: currentOffset), points: points).y))")
            }
            .font(.caption)
        }
    }
    
    var body: some View {
        let tapDrag = DragGesture(minimumDistance: 0)
        let tap = TapGesture(count: 1)
            .sequenced(before: tapDrag)
            .onEnded { value in
                if !self.showCrosshair {
                    self.showCrosshair = true
                }
                switch value {
                case .second((), let drag):
                    if let drag = drag {
                        withAnimation(.spring()) {
                            self.currentOffset.width = drag.location.x - self.size.width / 2
                            self.currentOffset.height = drag.location.y - self.size.height / 2
                            self.offset = self.currentOffset
                        }
                    }
                default:
                    break
                }
        }
        
        return ZStack {
            ChartGrid(xSteps: 10, ySteps: 20)
                .stroke(Color.systemGray4,
                        style: StrokeStyle(lineWidth: 0.5, dash: [12, 6]))
                /// Shape не будет регистрировать тапы на фоне
                /// поэтому нужна суперпрозрачная подложка (.clear не рабоатет)
                .background(Color.gray.opacity(0.001))
                .gesture(tap)
            
            Chart(points: self.points)
                .stroke(Color.blue)
            
            showCrosshair ? crosshair : nil
            
            showCrosshair ? nearestPoint : nil
        }
        .widthPref()
        .heightPref()
        .onPreferenceChange(WidthPref.self) { self.size.width = $0 }
        .onPreferenceChange(HeightPref.self) { self.size.height = $0 }
    }
    
    func nearestPoint(target: CGPoint, points: [CGPoint]) -> CGPoint {
        func distance(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
            let a = abs(point1.x - point2.x)
            let b = abs(point1.y - point2.y)
            return (a * a + b * b).squareRoot()
        }
        func nearestToTarget(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            let distance1 = distance(target, point1)
            let distance2 = distance(target, point2)
            if distance1 < distance2 {
                return point1
            } else {
                return point2
            }
        }
        
        if points.isEmpty { return target }
        
        var nearest = points[0]
        if points.count > 1 {
            for i in 1..<points.count {
                nearest = nearestToTarget(nearest, points[i])
            }
        }
        return nearest
    }
}

struct NearestPoint_Previews: PreviewProvider {
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
        NearestPoint(points: points)
            .frame(width: 350, height: 700)
    }
}
