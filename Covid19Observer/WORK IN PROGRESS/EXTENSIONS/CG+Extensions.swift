//
//  CG+Extensions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 07.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension CGSize {
    
    static func +(_ left: CGSize, _ right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width,
                      height: left.height + right.height)
    }

    static func -(_ left: CGSize, _ right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width,
                      height: left.height - right.height)
    }

    static func /(_ left: CGSize, _ right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right,
                      height: left.width / right)
    }
    
    /// Translates offset in iOS flipped-coordinate space to normal (as in Core Graphics) coordinate.
    /// In the default Core Graphics coordinate space, the origin is located in the lower-left corner of the rectangle and the rectangle extends towards the upper-right corner.
    /// - Parameter offset: offset (CGSize)
    /// - Returns: CGPoint in nornal coordinate space
    func cgCoordinate(for offset: CGSize, points: [CGPoint], size: CGSize) -> CGPoint {
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// To rescale a range between an arbitrary set of values [a, b]: x' = (x - min) * (b - a) / (max - min) + a
        ///
        //  MARK: FINISH THIS
        //  АНАЛОГИЧНО использовать minX и minY
        //
        
        guard points.isNotEmpty else { return .zero }
        
        let minX = points.map { $0.x }.min()!
        let maxX = points.map { $0.x }.max()!
        let minY = points.map { $0.y }.min()!
        let maxY = points.map { $0.y }.max()!
        
        /// нормировка, сдвиг, масштабирование на размеры и еще сдвиг
        let x = (offset.width / size.width + 1/2) * (maxX - minX) + minX
        /// нормировка, сдвиг, переворот (1 - 1/2 = 1/2), масштабирование на размеры и еще сдвиг
        let y = (1/2 - offset.height / size.height) * (maxY - minY) + minY
        
        return CGPoint(x: x, y: y)
        //        return CGPoint(x: (offset.width + size.width / 2) * maxX / size.width,
        //                       y: (size.height / 2 - offset.height) * maxY / size.height)
    }
    
    /// Rescale offset in the view to the point coordinate
    /// - Parameters:
    ///   - viewSize: viewSize hosting offset
    ///   - plotArea: plot area for points, usually  defined by minX, minY, maxX, maxY, but could be arbitrary
    /// - Returns: point in the plot area
    func rescaleOffsetToPoint(from viewSize: CGSize, into plotArea: CGRect) -> CGPoint {
        rescaleOffsetToPoint(offset: self, viewSize: viewSize, plotArea: plotArea)
    }
    
    /// Rescale offset in the view to the point coordinate
    /// - Parameters:
    ///   - offset: offset in the View
    ///   - viewSize: viewSize hosting offset
    ///   - plotArea: plot area for points, usually  defined by minX, minY, maxX, maxY, but could be arbitrary
    /// - Returns: point in the plot area
    private func rescaleOffsetToPoint(offset: CGSize, viewSize: CGSize, plotArea: CGRect) -> CGPoint {
        
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// To rescale a range between an arbitrary set of values [a, b]: x' = (x - min) * (b - a) / (max - min) + a
        
        let x: CGFloat
        if viewSize.width == 0 {
            x = 0
        } else {
            /// нормировка на размер View, сдвиг, масштабирование на целевые размеры и еще сдвиг
            x = (offset.width / viewSize.width + 1/2) * plotArea.width + plotArea.minX
        }
        
        let y: CGFloat
        if viewSize.height == 0 {
            y = 0
        } else {
            /// нормировка на размер View, сдвиг и переворот (1 - 1/2 = 1/2), масштабирование на целевые размеры и еще сдвиг
            y = (1/2 - offset.height / viewSize.height) * plotArea.height + plotArea.minY
        }
        
        return CGPoint(x: x, y: y)
    }
}

extension CGPoint {
    
    /// Calculates 2D plot area (bounds) for series of points.
    /// - Parameter points: series of points
    /// - Returns: plot area
    static func plotAreaForPoints(_ points: [CGPoint]) -> CGRect {
        guard points.isNotEmpty else { return .zero }
        
        let minX = points.map { $0.x }.min()!
        let maxX = points.map { $0.x }.max()!
        let minY = points.map { $0.y }.min()!
        let maxY = points.map { $0.y }.max()!
        
        return CGRect(x: minX,
                      y: minY,
                      width: maxX - minX,
                      height: maxY - minY)
    }
    
    static func plotAreaForAxises(axisX: Axis, axisY :Axis) -> CGRect {
        return CGRect(x: axisX.bottom,
                      y: axisY.bottom,
                      width: axisX.top - axisY.bottom,
                      height: axisY.top - axisY.bottom)
    }
    
    /// Rescaling: returns ofset in the target iOS coordinate space (View Space) for CGPoint in sourceSpace. The opposite to cgCoordinate function.
    /// - Parameters:
    ///   - sourceSpace: plot area for points, usually  defined by minX, minY, maxX, maxY, but could be arbitrary
    ///   - targetViewSize: <#targetViewSize description#>
    /// - Returns: offset size in the targetViewSize
    func rescaleToOffset(sourceSpace: CGRect, targetViewSize: CGSize) -> CGSize {
        rescaleToOffset(source: self, sourceSpace: sourceSpace, targetViewSize: targetViewSize)
    }
    
    
    /// Rescaling: returns ofset in the target iOS coordinate space (View Space) for CGPoint in sourceSpace. The opposite to cgCoordinate function.
    /// - Parameter point: CGPoint in iOS coordinate space to translate to offset
    /// - Parameter sourceSpace: plot area for points, usually  defined by minX, minY, maxX, maxY, but could be arbitrary
    /// - Parameter targetViewSize: <#targetSpaceSize description#>
    /// - Returns: offset size in the targetViewSize
    private func rescaleToOffset(source point: CGPoint,/* points: [CGPoint],*/ sourceSpace: CGRect, targetViewSize: CGSize) -> CGSize {
        //        guard sourceSpace == .zero || targetViewSize == .zero else { return .zero }
        
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// To rescale a range between an arbitrary set of values [a, b]: x' = (x - min) * (b - a) / (max - min) + a
        
        let x : CGFloat
        if sourceSpace.width == 0 {
            x = 0
        } else {
            /// сдвиг и нормировка
            x = (point.x - sourceSpace.minX) / (sourceSpace.width)
        }
        
        let y: CGFloat
        if sourceSpace.height == 0 {
            y = 0
        } else {
            /// сдвиг и нормировка
            y = (point.y - sourceSpace.minY) / (sourceSpace.height)
        }
        
        /// масштабирование на размеры
        return CGSize(width: (x - 1/2) * targetViewSize.width,
                      height: (1/2 - y) * targetViewSize.height)
    }
    
    
    /// Find the nearest to the `target` (self) point in the array. 2D or 1D (X axis) option.
    /// - Parameters:
    ///   - points: <#points description#>
    ///   - is2D: Use both X and Y axises (true) or just X (false)
    /// - Returns: closest af all points to `target` (self)
    func nearestPoint(points: [CGPoint], is2D: Bool) -> CGPoint {
        nearestPoint(target: self, points: points, is2D: is2D)
    }
    
    /// Find the nearest to the `target` point in the array. 2D or 1D (X axis) option.
    /// - Parameters:
    ///   - target: target point
    ///   - points: <#points description#>
    ///   - is2D: Use both X and Y axises (true) or just X (false)
    /// - Returns: closest af all points to `target`
    private func nearestPoint(target: CGPoint, points: [CGPoint], is2D: Bool) -> CGPoint {
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
