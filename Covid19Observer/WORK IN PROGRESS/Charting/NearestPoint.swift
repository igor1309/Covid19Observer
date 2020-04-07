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
    
    var tapPoint: some View {
        ZStack {
            Circle()
                .fill(Color.primary)
                //            .stroke(Color.primary)
                //                .opacity(0.5)
                .frame(width: 4, height: 4)
            
            VStack(alignment: .leading) {
                Text("x: \(Int(offset.width)) : \(Int(cgCoordinate(for: currentOffset).x))")
                Text("y: \(Int(offset.height)) : \(Int(cgCoordinate(for: currentOffset).y))")
            }
            .font(.caption)
        }
        .padding(8)
        .offset(currentOffset)
    }
    
    let strokeColor = Color.systemGray2
    let style = StrokeStyle(lineWidth: 1, dash: [12, 4])
    let crosshairLineWidth: CGFloat = 2
    
    var is2D: Bool
    
    var nearestPoint: some View {
        let nearestPointOffset = offsetFromCGCoordinate(for: nearestPoint(target: cgCoordinate(for: currentOffset), points: points, is2D: is2D))
        
        return ZStack {
            VerticalLine()
                .stroke(strokeColor, style: style)
                .opacity(0.5)
                .frame(width: crosshairLineWidth)
                .background(
                    Color.systemGray6.opacity(0.01)
            )
                .offset(x: nearestPointOffset.width)
            
            HorizontalLine()
                .stroke(strokeColor, style: style)
                .opacity(0.5)
                .frame(height: crosshairLineWidth)
                .background(
                    Color.systemGray6.opacity(0.01)
            )
                .offset(y: nearestPointOffset.height)
            
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
                .offset(nearestPointOffset)
            
            VStack(alignment: .leading) {
                Text("x: \(nearestPoint(target: cgCoordinate(for: currentOffset), points: points, is2D: is2D).x, specifier: "%.2f")")
                Text("y: \(nearestPoint(target: cgCoordinate(for: currentOffset), points: points, is2D: is2D).y, specifier: "%.2f")")
            }
            .padding(8)
            .foregroundColor(.secondary)
            .font(.caption)
            .roundedBackground(cornerRadius: 8)
            .offset(legendOffset(from: nearestPointOffset))
            .padding(8)
            .widthPref()
            .heightPref()
        }
    }
    
    @State private var legendSize: CGSize = .zero
    func legendOffset(from offset: CGSize) -> CGSize {
        var newOffset = offset
        
        if offset.width + legendSize.width > size.width / 2 {
            newOffset.width -= legendSize.width / 2
        } else {
            newOffset.width += legendSize.width / 2
        }
        
        if offset.height - legendSize.height / 1 < -size.height / 2 {
            newOffset.height += legendSize.height / 2
        } else {
            newOffset.height -= legendSize.height / 2
        }
        
        return newOffset
    }
    
    var body: some View {
        let drag = DragGesture()
            .onChanged { drag in
                withAnimation(.spring()) {
                    self.currentOffset = self.offset + drag.translation
                }
        }
        .onEnded { drag in
            self.currentOffset = self.offset + drag.translation
            self.offset = self.currentOffset
        }
        
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
            
            Color.black.opacity(0.001)
                /// Shape не будет регистрировать тапы на фоне
                /// поэтому нужна суперпрозрачная подложка (.clear не рабоатет)
                .background(Color.gray.opacity(0.001))
                .gesture(tap)
            
            //            showCrosshair ? tapPoint : nil
            
            showCrosshair ?
                nearestPoint
                    /// MARK: gesture grad писалась для произвольной точки
                    /// вероятно для nearestPoint нужно изменить математику
                    .gesture(drag)
                    .onTapGesture(count: 2) {
                        self.showCrosshair = false
                }
                .onPreferenceChange(WidthPref.self) {
                    self.legendSize.width = $0
                }
                .onPreferenceChange(HeightPref.self) {
                    self.legendSize.height = $0
                }
                : nil
        }
        .widthPref()
        .heightPref()
        .onPreferenceChange(WidthPref.self) { self.size.width = $0 }
        .onPreferenceChange(HeightPref.self) { self.size.height = $0 }
    }
    
    
    /// Translates offset in iOS flipped-coordinate space to normal (as in Core Graphics) coordinate.
    /// In the default Core Graphics coordinate space, the origin is located in the lower-left corner of the rectangle and the rectangle extends towards the upper-right corner.
    /// - Parameter offset: offset (CGSize)
    /// - Returns: CGPoint in nornal coordinate space
    func cgCoordinate(for offset: CGSize) -> CGPoint {
        
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// To rescale a range between an arbitrary set of values [a, b]
        /// x' = (x - min) * (b - a) / (max - min) + a
        ///
        //  MARK: FINISH THIS
        //  АНАЛОГИЧНО использовать minX и minY
        //
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 1
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 1
        
        /// нормировка, сдвиг, масштабирование на размеры и еще сдвиг
        let x = (offset.width / size.width + 1/2) * (maxX - minX) + minX
        /// нормировка, сдвиг, переворот (1 - 1/2 = 1/2), масштабирование на размеры и еще сдвиг
        let y = (1/2 - offset.height / size.height) * (maxY - minY) + minY
        
        return CGPoint(x: x, y: y)
        //        return CGPoint(x: (offset.width + size.width / 2) * maxX / size.width,
        //                       y: (size.height / 2 - offset.height) * maxY / size.height)
        
        let plotArea = plotAreaForPoints(points)
        print(points)
        print(plotArea)
        //
        return offset.rescaleOffsetToPoint(from: size, to: plotArea)
    }
    
    
    /// The opposite to cgCoordinate function: returns ofset in iOS coordinate space from CGPoint.
    /// - Parameter point: CGPoint in iOS coordinate space to translate to offset
    /// - Returns: offset size
    func offsetFromCGCoordinate(for point: CGPoint) -> CGSize {
        
        
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 1
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 1
        
        /// сдвиг и нормировка
        let x = (point.x - minX) / (maxX - minX)
        /// сдвиг и нормировка
        let y = (point.y - minY) / (maxY - minY)
        
        /// масштабирование на размеры
        return CGSize(width: (x - 1/2) * size.width,
                      height: (1/2 - y) * size.height)
        //        return CGSize(width: (point.x - minX) / (maxX - minX) * size.width - size.width / 2,
        //                      height: (1 - (point.y - minY) / (maxY - minY)) * size.height - size.height / 2)
        
        let plotArea = plotAreaForPoints(points)
        print("offsetFromCGCoordinate calculated")
        return point.rescaleToOffset(sourceSpace: plotArea,
                                     targetViewSize: size)
    }
    
    
    /// Find the nearest to the `target` point in the array. 2D or 1D (X axis) option.
    /// - Parameters:
    ///   - target: target point
    ///   - points: <#points description#>
    ///   - is2D: Use both X and Y axises (true) or just X (false)
    /// - Returns: closest af all points to `target`
    func nearestPoint(target: CGPoint, points: [CGPoint], is2D: Bool) -> CGPoint {
        func distance(_ point1: CGPoint, _ point2: CGPoint, is2D: Bool) -> CGFloat {
            if is2D {
                let a = abs(point1.x - point2.x)
                let b = abs(point1.y - point2.y)
                return (a * a + b * b).squareRoot()
            } else {
                return abs(point1.x - point2.x)
            }
        }
        func nearestToTarget(_ point1: CGPoint, _ point2: CGPoint, is2D: Bool) -> CGPoint {
            let distance1 = distance(target, point1, is2D: is2D)
            let distance2 = distance(target, point2, is2D: is2D)
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
                nearest = nearestToTarget(nearest, points[i], is2D: is2D)
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
        CGPoint(x: 80, y: 200),
        CGPoint(x: 85, y: 200),
        CGPoint(x: 100, y: 190)
    ]
    
    static var previews: some View {
        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
            
            ZStack {
                
                ChartGrid(xSteps: 10, ySteps: 20)
                    .stroke(Color.systemGray,
                            style: StrokeStyle(lineWidth: 0.5, dash: [12, 6]))
                    .opacity(0.5)
                
                Chart(points: self.points)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                
                NearestPoint(points: points, is2D: false)
            }
            .frame(width: 350, height: 700)
        }
        .environment(\.colorScheme, .dark)
    }
}
