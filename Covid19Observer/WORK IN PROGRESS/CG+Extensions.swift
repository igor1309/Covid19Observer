//
//  CG+Extensions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 07.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension CGSize {
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
    func rescaleOffsetToPoint(from viewSize: CGSize, to plotArea: CGRect) -> CGPoint {
        rescaleOffsetToPoint(offset: self, viewSize: viewSize, plotArea: plotArea)
    }
    
    /// Rescale offset in the view to the point coordinate
    /// - Parameters:
    ///   - offset: offset in the View
    ///   - viewSize: viewSize hosting offset
    ///   - plotArea: plot area for points, usually  defined by minX, minY, maxX, maxY, but could be arbitrary
    /// - Returns: point in the plot area
    private func rescaleOffsetToPoint(offset: CGSize, viewSize: CGSize, plotArea: CGRect) -> CGPoint {
        guard viewSize == .zero || plotArea == .zero else { return .zero }
        
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// To rescale a range between an arbitrary set of values [a, b]: x' = (x - min) * (b - a) / (max - min) + a
        
        /// нормировка на размер View, сдвиг, масштабирование на целевые размеры и еще сдвиг
        let x = (offset.width / viewSize.width + 1/2) * plotArea.width + plotArea.minX
        /// нормировка на размер View, сдвиг и переворот (1 - 1/2 = 1/2), масштабирование на целевые размеры и еще сдвиг
        let y = (1/2 - offset.height / viewSize.height) * plotArea.height + plotArea.minY
        
        return CGPoint(x: x, y: y)
    }
}


//  MARK: - MOVE TO SOME CLASS OR ENUM???
//
/// Calculates 2D plot area (bounds) for series of points.
/// - Parameter points: series of points
/// - Returns: plot area
func plotAreaForPoints(_ points: [CGPoint]) -> CGRect {
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


extension CGPoint {
    
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
        guard sourceSpace == .zero || targetViewSize == .zero else { return .zero }
        
        /// https://en.wikipedia.org/wiki/Feature_scaling
        /// To rescale a range between an arbitrary set of values [a, b]: x' = (x - min) * (b - a) / (max - min) + a
        
        /// сдвиг и нормировка
        let x = (point.x - sourceSpace.minX) / (sourceSpace.width)
        /// сдвиг и нормировка
        let y = (point.y - sourceSpace.minY) / (sourceSpace.height)
        
        /// масштабирование на размеры
        return CGSize(width: (x - 1/2) * targetViewSize.width,
                      height: (1/2 - y) * targetViewSize.height)
    }
}
