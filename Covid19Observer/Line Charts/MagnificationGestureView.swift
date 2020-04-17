//
//  MagnificationGestureView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 15.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MagnifiableView<Content>: View where Content: View {
    @GestureState private var magnifyBy = CGFloat(1.0)
    @State private var scale = CGFloat(1.0)
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, transaction in
                withAnimation(.interactiveSpring()) {
                    /// gestureState is magnifyBy
                    gestureState = currentState
                }
        }
        .onEnded { value in
            self.scale *= value
        }
    }
    
    var width: CGFloat
    var height: CGFloat
    var alignment: Alignment = .center
    var content: () -> Content
    
    var body: some View {
        content()
            .frame(width: width * magnifyBy * scale,
                   height: height * magnifyBy * scale,
                   alignment: alignment)
            .gesture(magnification)
            .onTapGesture(count: 2) { self.scale = 1 }
    }
}

struct MagnificationGestureView: View {
    
    @GestureState private var magnifyBy = CGFloat(1.0)
    @State private var scale = CGFloat(1.0)
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, transaction in
                /// gestureState is magnifyBy
                gestureState = currentState
        }
        .onEnded { value in
            self.scale *= value
        }
    }
    
    var body: some View {
        HStack {
            MagnifiableView(width: 120, height: 120, alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color.blue)
            }
            
            
            Circle()
                ///  after onEnded magnifyBy=1 again
                .frame(width: 100 * magnifyBy * scale,
                       height: 100 * magnifyBy * scale,
                       alignment: .center)
                .gesture(magnification)
                .onTapGesture(count: 2) {
                    self.scale = 1
            }
        }
    }
}
struct MagnificationGestureView_Previews: PreviewProvider {
    static var previews: some View {
        MagnificationGestureView()
    }
}
