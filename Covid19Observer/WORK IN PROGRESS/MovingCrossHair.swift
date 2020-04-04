//
//  MovingCrossHair.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 04.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MovingCrossHairTest: View {
    var body: some View {
        GeometryReader { geo in
            MovingCrossHair(size: geo.size)
        }
    }
}

struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addLines([
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.midX, y: rect.maxY)
        ])
        return p
    }
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addLines([
            CGPoint(x: rect.minX, y: rect.midY),
            CGPoint(x: rect.maxX, y: rect.midY)
        ])
        return p
    }
}

struct MovingCrossHair: View {
    var size: CGSize
    
    @State private var currentOffset: CGSize = .zero
    @State private var offset: CGSize = .zero
    
    @State private var showCrosshair = true
    @State private var crosshairLegendSize: CGSize = .zero
//    @State private var width: CGFloat = 0
//    @State private var height: CGFloat = 0

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
        
        let strokeColor = Color.systemGray4
        let style = StrokeStyle(lineWidth: 1,
                                dash: [10, 3])
        return ZStack {
            GridView()
//            Rectangle()
//                .fill(Color.systemBackground)
                .gesture(tap)
            
            if self.showCrosshair {
                ZStack {
                    
                    VStack(alignment: .leading) {
                        Text("w: \(crosshairLegendSize.width)")
                        Text("h: \(crosshairLegendSize.height)")
                        Text("offset.x: \(currentOffset.width)")
                        Text("offset.y: \(currentOffset.height)")
                        Text("x: \(size.width / 2)")
                        Text("y: \(size.height / 2)")
                    }
                    .padding(8)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .roundedBackground(cornerRadius: 8)
                    .offset(clampOffset(currentOffset))
                    .padding(8)
                    .widthPref()
                    .heightPref()
                    
                    ZStack {
                        VerticalLine()
                            .stroke(strokeColor, style: style)
                            .frame(width: 20)
                            .background(
                                Color.systemGray6.opacity(0.01)
                        )
                            .offset(x: currentOffset.width)
                        
                        HorizontalLine()
                            .stroke(strokeColor, style: style)
                            .frame(height: 20)
                            .background(
                                Color.systemGray6.opacity(0.01)
                        )
                            .offset(y: currentOffset.height)
                    }
                }
                .gesture(drag)
                .onPreferenceChange(WidthPref.self) { self.crosshairLegendSize.width = $0 }
                .onPreferenceChange(HeightPref.self) { self.crosshairLegendSize.height = $0 }
            }
        }
    }
    
    func clampOffset(_ offset: CGSize) -> CGSize {
        var newOffset = offset
        
        if offset.width + crosshairLegendSize.width > size.width / 2 {
            newOffset.width -= crosshairLegendSize.width / 2
        } else {
            newOffset.width += crosshairLegendSize.width / 2
        }
        
        if offset.height - crosshairLegendSize.height / 1 < -size.height / 2 {
            newOffset.height += crosshairLegendSize.height / 2
        } else {
            newOffset.height -= crosshairLegendSize.height / 2
        }
        
        return newOffset
    }
}

struct MovingCrossHair_Previews: PreviewProvider {
    static var previews: some View {
        MovingCrossHairTest()
            .environment(\.colorScheme, .dark)
    }
}
