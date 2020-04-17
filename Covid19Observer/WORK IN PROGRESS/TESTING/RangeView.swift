//
//  RangeView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 15.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// https://github.com/BestKora/ChartsView-SwiftUI/blob/master/RectangleSwiftUI/Graphs/IndicatorView.swift
struct RangeViewWrapper: View {
    //  MARK: move @State vars to Environment
    /// Bounds in (0,1) range
    @State private var lowerBound: CGFloat = 0.1
    @State private var upperBound: CGFloat = 0.8
    
    let height: CGFloat = 60
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Slider(value: self.$lowerBound, in: 0...1)
                Slider(value: self.$upperBound, in: 0...1)
                
                RangeView(rangeWidth: geo.size.width,
                          rangeHeight: self.height,
                          lowerBound: self.$lowerBound,
                          upperBound: self.$upperBound)
            }
        }
        .padding(.top, 250)
    }
}

struct RangeView: View {
    
    var rangeWidth: CGFloat
    var rangeHeight: CGFloat
    
    @Binding var lowerBound: CGFloat
    @Binding var upperBound: CGFloat
    
    @State var prevTranslation: CGFloat = 0
    
    let minRectWidth: CGFloat = 12
    
    var leadingViewWidth:  CGFloat { rangeWidth * lowerBound }
    var centerViewWidth:   CGFloat { rangeWidth * (upperBound - lowerBound) }
    var trailingViewWidth: CGFloat { rangeWidth * (1 - upperBound) }
    
    var leadingView: some View {
        ZStack(alignment: .trailing) {
            Rectangle()
                .fill(Color.green)
            Capsule()
                .fill(Color.secondary)
                .frame(width: 5)
                .padding(.vertical, 6)
                .padding(.trailing, 3)
        }
        .frame(width: leadingViewWidth)
        .gesture(DragGesture(minimumDistance: 1)
        .onChanged { value in
            withAnimation(.linear) {
                let translationX = value.translation.width
                let normalizedTranslationDelta = (translationX - self.prevTranslation) / self.rangeWidth
                self.lowerBound += normalizedTranslationDelta
                self.prevTranslation = translationX
            }
        }
        .onEnded { value in
            self.prevTranslation = 0.0
        })
    }
    
    var centerView: some View {
        Rectangle()
            .fill(Color.systemYellow)//.secondarySystemFill)
            .frame(width: centerViewWidth)
            .gesture(DragGesture(minimumDistance: 1)
                .onChanged { value in
                    withAnimation(.linear) {
                        let translationX = value.translation.width
                        let normalizedTranslationDelta = (translationX - self.prevTranslation) / self.rangeWidth
                        self.lowerBound += normalizedTranslationDelta
                        self.upperBound += normalizedTranslationDelta
                        self.prevTranslation = translationX
                    }
            }
            .onEnded { value in
                self.prevTranslation = 0.0
            })
    }
    
    var trailingView: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.blue)
            Capsule()
                .fill(Color.secondary)
                .frame(width: 5)
                .padding(.vertical, 6)
                .padding(.leading, 3)
        }
        .frame(width: trailingViewWidth)
        .gesture(DragGesture(minimumDistance: 1)
        .onChanged { value in
            //                    withAnimation(.linear) {
            let translationX = value.translation.width
            let normalizedTranslationDelta = (translationX - self.prevTranslation) / self.rangeWidth
            self.upperBound += normalizedTranslationDelta
            self.prevTranslation = translationX
            //                    }
        }
        .onEnded { value in
            self.prevTranslation = 0.0
        })
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
//                Rectangle()
//                    .fill(Color.orange)
//                    .frame(width: rangeWidth - trailingViewWidth)
//                    .gesture(DragGesture(minimumDistance: 1)
//                        .onChanged { value in
//                            //                    withAnimation(.linear) {
//                            let translationX = value.translation.width
//                            let normalizedTranslationDelta = (translationX - self.prevTranslation) / self.rangeWidth
//                            self.upperBound = self.upperBound + normalizedTranslationDelta
//                            self.prevTranslation = translationX
//                            //                    }
//                    }
//                    .onEnded { value in
//                        self.prevTranslation = 0.0
//                    })
                
//                Rectangle()
//                    .fill(Color.pink)
                
                leadingView
//                Color.red
                trailingView
            }
            .frame(height: rangeHeight)
            
            HStack(spacing: 0) {
                
                leadingView
                
                centerView
                
                trailingView
                
            }
            .frame(height: rangeHeight)
        }
    }
}

struct RangeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            RangeViewWrapper()
        }
        .environment(\.colorScheme, .dark)
    }
}
