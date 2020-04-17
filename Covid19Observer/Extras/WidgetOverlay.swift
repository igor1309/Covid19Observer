//
//  WidgetOverlay.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 17.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct WidgetOverlay<Content: View>: View {
    
    let content: () -> Content
    
    @State private var widgetOffset: CGSize = .zero
    @State private var prevTranslation: CGSize = .zero
    @State private var size: CGRect = .zero
    
    func widget(in rect: CGSize) -> some View {
        let drag = DragGesture()
            .onChanged { value in
                withAnimation(.spring()) {
                    let translation = value.translation - self.prevTranslation
                    self.prevTranslation = value.translation
                    self.widgetOffset = self.widgetOffset + translation
                    /// contain within bounds
                    self.widgetOffset.width = max(-(rect.width - self.size.width),
                                                  min(0,
                                                      self.widgetOffset.width))
                    self.widgetOffset.height = max(-(rect.height - self.size.height),
                                                   min(0,
                                                       self.widgetOffset.height))
                }
        }
        .onEnded {_ in
            self.prevTranslation = .zero
        }
        
        return content()
//            .padding()
            .fixedSize()
            //  .sizePreference()
            .saveBounds(viewId: 101)
            .frame(width: size.width, height: size.height)
            .offset(widgetOffset)
            .gesture(drag)
            .onTapGesture(count: 2) {
                self.widgetOffset = .zero
        }
//        .onPreferenceChange(SizePreferenceKey.self) { self.size = $0 }
        .retrieveBounds(viewId: 101, $size)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                // this is a phantom view that is used to calculate the item size
                Color.clear
                
                self.widget(in: geo.size)
            }
        }
    }
}

struct WidgetOverlay_Previews: PreviewProvider {
    
    static var widget: some View {
        WidgetOverlay {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.8))
                
                VStack(alignment: .leading) {
                    Text("Widget Here")
                    Text("Really Here")
                }
                .font(.footnote)
                .padding(8)
            }
        }
    }
    
    static var previews: some View {
        Color.blue.opacity(0.3)
            .overlay(widget)
            .padding()
    }
}
