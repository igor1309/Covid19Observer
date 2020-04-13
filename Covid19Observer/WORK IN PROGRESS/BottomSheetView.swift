//
//  BottomSheetView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    let snapRatio: CGFloat = 0.5
    
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let content: Content
    
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        let minHeightRatio: CGFloat = 0.10
        
        self._isOpen = isOpen
        self.maxHeight = maxHeight
        self.minHeight = maxHeight * minHeightRatio
        self.content = content()
    }
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    @GestureState private var translation: CGFloat = 0
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.secondary)
            .frame(width: 60, height: 10)
    }
    
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                self.indicator.padding()
                self.content
            }
            .frame(width: geo.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .frame(height: geo.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * self.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

struct BottomSheetViewTESTING: View {
    @State private var bottomSheetShown = false
    
    var body: some View {
        GeometryReader { geometry in
            Color.green
            
            BottomSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: geometry.size.height * 0.7
            ) {
                Color.blue
            }
        }.edgesIgnoringSafeArea(.all)
    }
}


struct BottomSheetViewTESTING_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            BottomSheetViewTESTING()
        }
        .environment(\.colorScheme, .dark)
    }
}
