//
//  TapPointer.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 05.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TapPointer: View {

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
    
    @State private var size: CGSize = .zero
    @State private var currentOffset: CGSize = .zero
    @State private var offset: CGSize = .zero

    var tapPoint: some View {
        ZStack {
            Circle()
                .fill(Color.primary)
                .frame(width: 4, height: 4)
            
            VStack(alignment: .leading) {
                Text("x: \(Int(offset.width)) : \(Int(currentOffset.rescaleOffsetToPoint(from: size, into: plotArea).x))")
                Text("y: \(Int(offset.height)) :  \(Int(currentOffset.rescaleOffsetToPoint(from: size, into: plotArea).y))")
            }
            .font(.caption)
        }
        .padding(8)
        .offset(currentOffset)
    }
    
    @State private var legendSize: CGSize = .zero
    var pointer: some View {
        
        let strokeColor = Color.systemGray2
        let style = StrokeStyle(lineWidth: 1, dash: [12, 4])
        let lineWidth: CGFloat = 2
        
        let nearestPoint =
            currentOffset
                .rescaleOffsetToPoint(from: size,
                                      into: plotArea)
                .nearestPoint(points: points, is2D: is2D)
        let pointerOffset =
            nearestPoint
                .rescaleToOffset(sourceSpace: plotArea,
                                 targetViewSize: size)
        
        func pointerLegendOffset(from offset: CGSize) -> CGSize {
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
        
        return ZStack {
            VerticalLine()
                .stroke(strokeColor, style: style)
                .opacity(0.5)
                .background(Color.systemGray6.opacity(0.01))
                .frame(width: lineWidth)
                .offset(x: pointerOffset.width)
            
            HorizontalLine()
                .stroke(strokeColor, style: style)
                .opacity(0.5)
                .background(Color.systemGray6.opacity(0.01))
                .frame(height: lineWidth)
                .offset(y: pointerOffset.height)
            
            Circle()
                .fill(Color.orange)
                .frame(width: 10, height: 10)
                .offset(pointerOffset)
            
            VStack(alignment: .leading) {
                Text("x: " + Double(nearestPoint.x).formattedGrouped)
                Text("y: " + Double(nearestPoint.y).formattedGrouped)
            }
            .fixedSize()
            .padding(8)
            .foregroundColor(.secondary)
            .font(.caption)
            .roundedBackground(cornerRadius: 8)
            .offset(pointerLegendOffset(from: pointerOffset))
            .padding(8)
                .saveSize(viewId: 112)
        }
        .retrieveSize(viewId: 112, $legendSize)
    }
    
    @State private var prevTranslation: CGSize = .zero
    

    @State private var showPointer = false
    @State private var pointerSize: CGSize = .zero

    var body: some View {
        let drag = DragGesture()
            .onChanged { value in
                withAnimation(.spring()) {
                    let translation = value.translation - self.prevTranslation
                    self.currentOffset = self.offset + translation
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
                .gesture(tap)
                .saveSize(viewId: 111)
            
//             showPointer ? tapPoint : nil
            
            showPointer
                ? pointer
                    // MARK: -FINISH THIS
                    // DRAG НУЖНО ПОЧИНИТЬ
                    // gesture grad писалась для произвольной точки
                    // вероятно для nearestPoint нужно изменить математику
                    .gesture(drag)
                    /// turn off pointer with double tap
                    .onTapGesture(count: 2) { self.showPointer = false }
                : nil
        }
        .retrieveSize(viewId: 111, $size)
        .retrieveSize(viewId: 112, $pointerSize)
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
            //            Color.black.edgesIgnoringSafeArea(.all)
            
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
