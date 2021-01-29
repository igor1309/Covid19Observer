//
//  TapPointer.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 05.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TapPointer: View {
    @EnvironmentObject var settings: Settings
    
    let points: [CGPoint]
    let is2D: Bool
    let plotArea: CGRect
    
    init(points: [CGPoint], plotArea: CGRect? = nil, is2D: Bool) {
        self.points = points
        self.is2D = is2D
        if plotArea == nil {
            self.plotArea = CGPoint.plotAreaForPoints(points)
        } else {
            self.plotArea = plotArea!
        }
    }
    
    @State private var showChartSettings = false

    @State private var viewSize: CGSize = .zero
    @State private var showPointer = false
    @State private var prevTranslation: CGSize = .zero
    @State private var currentOffset: CGSize = .zero
    @State private var offsetDELETE: CGSize = .zero
    @State private var legendSize: CGSize = .zero
    
    var pointer: some View {
        
        let strokeColor = Color.systemGray2
        let style = StrokeStyle(lineWidth: 1, dash: [12, 4])
        let lineWidth: CGFloat = 2
        
        let nearestPoint =
            currentOffset
                .rescaleOffsetToPoint(from: viewSize,
                                      into: plotArea)
                .nearestPoint(points: points, is2D: is2D)
        let pointerOffset =
            nearestPoint
                .rescaleToOffset(sourceSpace: plotArea,
                                 targetViewSize: viewSize)
        
        /// correct pointer legend offset to keep within view (chart area) bounds
        /// - Parameter pointerOffset: pointerOffset
        /// - Returns: corrected offset
        func pointerLegendOffset(for pointerOffset: CGSize) -> CGSize {
            var newOffset = pointerOffset
            
            if pointerOffset.width + legendSize.width > viewSize.width / 2 {
                newOffset.width -= legendSize.width / 2
            } else {
                newOffset.width += legendSize.width / 2
            }
            
            if pointerOffset.height - legendSize.height / 1 < -viewSize.height / 2 {
                newOffset.height += legendSize.height / 2
            } else {
                newOffset.height -= legendSize.height / 2
            }
            
            return newOffset
        }
        
        var verticalLine: some View {
            VerticalLine()
                .stroke(strokeColor, style: style)
                .opacity(0.5)
                .background(Color.systemGray6.opacity(0.01))
                .frame(width: lineWidth)
                .offset(x: pointerOffset.width)
        }
        
        var horizontalLine: some View {
            HorizontalLine()
                .stroke(strokeColor, style: style)
                .opacity(0.5)
                .background(Color.systemGray6.opacity(0.01))
                .frame(height: lineWidth)
                .offset(y: pointerOffset.height)
        }
        
        var dot: some View {
            Circle()
                .fill(Color.systemOrange)
                .frame(width: 10, height: 10)
                .offset(pointerOffset)
        }
        
        var legend: some View {
            let yStr = nearestPoint.y < 10
            ? Double(nearestPoint.y).formattedPercentageWithDecimals
            : Double(nearestPoint.y).formattedGrouped
            
           return VStack(alignment: .leading) {
                Text("x: " + Double(nearestPoint.x).formattedGrouped)
                Text("y: " + yStr)
            }
            .contentShape(Rectangle())
            .foregroundColor(.secondary)
            .font(.caption)
            .fixedSize()
            .padding(8)
            .roundedBackground(cornerRadius: 8)
            .offset(pointerLegendOffset(for: pointerOffset))
            .padding(8)
            .saveSize(viewId: 112)
            .onLongPressGesture(minimumDuration: 1.5) {
                    self.showChartSettings = true
            }
            .sheet(isPresented: $showChartSettings) {
                LineChartSettingsView()
                    .environmentObject(self.settings)
            }
        }
        
        return ZStack {
            verticalLine
            horizontalLine
            dot
            legend
        }
        .retrieveSize(viewId: 112, $legendSize)
    }
    
    var body: some View {
        let drag = DragGesture()
            .onChanged { value in
                withAnimation(.spring()) {
                    let translation = value.translation - self.prevTranslation
                    self.currentOffset = self.currentOffset + translation
                    self.prevTranslation = value.translation
                }
        }
        .onEnded { value in
            self.prevTranslation = .zero
        }
        
        let tapDrag = DragGesture(minimumDistance: 0)
        let tap = TapGesture(count: 1)
            .sequenced(before: tapDrag)
            .onEnded { value in
                if !self.showPointer {
                    self.showPointer = true
                }
                switch value {
                case .second((), let drag):
                    if let drag = drag {
                        withAnimation(.spring()) {
                            self.currentOffset.width = drag.location.x - self.viewSize.width / 2
                            self.currentOffset.height = drag.location.y - self.viewSize.height / 2
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
                .gesture(tap)
                .saveSize(viewId: 111)
            
            showPointer
                ? pointer
                    .gesture(drag)
                    /// turn off (hide) pointer with double tap
                    .onTapGesture(count: 2) { self.showPointer = false }
                : nil
        }
        .retrieveSize(viewId: 111, $viewSize)
    }
}


struct TapPointer_Previews: PreviewProvider {
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 10),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 20, y: 40),
        CGPoint(x: 30, y: 30),
        CGPoint(x: 48, y: 100),
        //        CGPoint(x: 50, y: 140),
        CGPoint(x: 50, y: 180),
        CGPoint(x: 80, y: 200),
        CGPoint(x: 85, y: 200),
        CGPoint(x: 100, y: 190)
    ]
    
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ZStack {
                
                ChartGrid(xSteps: 10, ySteps: 20)
                    .stroke(Color.systemGray,
                            style: StrokeStyle(lineWidth: 0.5, dash: [12, 6]))
                    .opacity(0.5)
                
                Chart(points: self.points)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                
                TapPointer(points: points, is2D: false)
            }
            .frame(width: 350, height: 700)
        }
        .environment(\.colorScheme, .dark)
    }
}
