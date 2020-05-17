//
//  SpinningArrowsWithSubscriber.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

struct SpinningArrowsWithSubscriberButton: View {
    var title: String? = nil
    let publisher: AnyPublisher<Bool, Never>
    let scale: Image.Scale = .medium
    let action: () -> ()

    var body: some View {
        Button(action: action) {
            HStack {
                SpinningArrowsWithSubscriber(publisher: publisher, scale: scale)
                
                if title != nil {
                    Text(title!)
                }
            }
        }
    }
}

struct SpinningArrowsWithSubscriber: View {
    var publisher: AnyPublisher<Bool, Never>
    var scale: Image.Scale = .small
    
    @State private var isUpdating: Bool = false
    
    var body: some View {
        Image(systemName: "arrow.2.circlepath")
            .foregroundColor(.accentColor)
            .imageScale(scale)
            .rotationEffect(.degrees(isUpdating ? 180 : 0))
            .animation(isUpdating
                ? Animation.linear(duration: 0.4).repeatForever(autoreverses: false)
                : .default)
            .onReceive(publisher) { self.isUpdating = $0 }
    }
}

private struct SpinningArrowsTesting: View {
    @State private var isUpdating = false
    
    var body: some View {
        
        let publisher = AnyPublisher<Bool, Never>(
            Just(isUpdating)
        )
        
        return VStack(spacing: 32) {
            Button(action: {
                self.isUpdating.toggle()
            }) {
                SpinningArrows(isUpdating: $isUpdating)
            }
            
            SpinningArrowsWithSubscriberButton(title: "Current", publisher: publisher) {}
            
            SpinningArrowsWithSubscriber(publisher: publisher)
            SpinningArrowsWithSubscriber(publisher: publisher, scale: .large)
            
            Button(isUpdating ? "stop" : "start") {
                self.isUpdating.toggle()
            }
        }
    }
}

private struct SpinningArrows: View {
    @Binding var isUpdating: Bool
    var scale: Image.Scale = .small
    
    var body: some View {
        Image(systemName: "arrow.2.circlepath")
            .imageScale(.small)
            .rotationEffect(.degrees(isUpdating ? 360 : 0))
            .animation(isUpdating
                ? Animation.linear(duration: 1.6).repeatForever(autoreverses: false)
                : .default)
    }
}

struct SpinningArrowsWithSubscriber_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            SpinningArrowsTesting()
        }
    }
}
