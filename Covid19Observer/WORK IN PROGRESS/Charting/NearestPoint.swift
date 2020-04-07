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
                Text("x: \(Int(offset.width)) : \(Int(currentOffset.rescaleOffsetToPoint(from: size, into: plotAreaForPoints(points)).x))")
                Text("y: \(Int(offset.height)) :  \(Int(currentOffset.rescaleOffsetToPoint(from: size, into: plotAreaForPoints(points)).y))")
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
        //        let nearestPT = nearestPoint(target: cgCoordinate(for: currentOffset), points: points, is2D: is2D)
        let nearestPT = currentOffset
            .rescaleOffsetToPoint(from: size, into: plotAreaForPoints(points))
            .nearestPoint(points: points, is2D: is2D)
        let nearestPointOffset = nearestPT
            .rescaleToOffset(sourceSpace: plotAreaForPoints(points),
                             targetViewSize: size)
                
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
                Text("x: " + Double(
                    currentOffset
                        .rescaleOffsetToPoint(from: size, into: plotAreaForPoints(points))
                        .nearestPoint(points: points, is2D: is2D)
                        .x)
                    .formattedGrouped)
                Text("y: " + Double(
                    currentOffset
                        .rescaleOffsetToPoint(from: size, into: plotAreaForPoints(points))
                        .nearestPoint(points: points, is2D: is2D)
                        .y)
                    .formattedGrouped)
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
            
            /// Shape не будет регистрировать тапы на фоне
            /// поэтому нужна суперпрозрачная подложка (.clear не рабоатет)
            Color.black.opacity(0.001)
                .background(Color.gray.opacity(0.001))
                .gesture(tap)
            
            // showCrosshair ? tapPoint : nil
            
            showCrosshair ?
                nearestPoint
                    // MARK: -FINISH THIS
                    // gesture grad писалась для произвольной точки
                    // вероятно для nearestPoint нужно изменить математику
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
}

public extension CGFloat {
    var formattedGroupedWithMax2Decimals: String {
        return Formatter.groupedWithMax2DecimalsFormat.string(for: Double(self)) ?? ""
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
