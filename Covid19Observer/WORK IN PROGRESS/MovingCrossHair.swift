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
    
    @State private var currentOffset: CGSize = .zero //CGSize(width: -100, height: -100)
    @State private var offset: CGSize = .zero //CGSize(width: -100, height: -100)
    @State private var showCrosshair = true
    
    @State private var width: CGFloat = 0
    
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
            Rectangle()
                .fill(Color.systemBackground)
                .gesture(tap)
            
            if self.showCrosshair {
                VStack(spacing: 0) {
                    
                    VStack(alignment: .leading) {
                        Text("x: \(currentOffset.width)")
                        Text("y: \(currentOffset.height)")
                    }
                    .padding(8)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .roundedBackground(cornerRadius: 8)
                    .offset(x: clampOffset(currentOffset.width))
                    .padding(8)
                        .widthPref()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    
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
                .onPreferenceChange(WidthPref.self) {
                    self.width = $0
                }
            }
        }
    }
    
    func clampOffset(_ offsetX: CGFloat) -> CGFloat {
        var newOffset = offsetX
        
        if offsetX + width / 2 > size.width / 2 {
            newOffset = size.width / 2 - width / 2
        } else if offsetX - width / 2 < -size.width / 2 {
            newOffset = -size.width / 2 + width / 2
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
