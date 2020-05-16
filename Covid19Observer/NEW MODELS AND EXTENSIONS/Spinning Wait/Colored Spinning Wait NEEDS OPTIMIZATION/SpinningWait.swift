//
//  SpinningWait.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SpinningWait: View {
    @Binding var isUpdating: Bool
    
    var size: CGFloat = 12
    
    var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: 16, dash: [3, 1]))
            .fill(AngularGradient(
                gradient: Gradient(colors: [Color.yellow, .pink, .green, .orange]),
                center: .center))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isUpdating ? 360 : 0))
            .animation(isUpdating
                ? Animation.linear(duration: 2.1).repeatForever(autoreverses: false)
                : .default)
    }
}

struct SpinningWaitTesting: View {
    @State private var isUpdating = false
    
    var body: some View {
        VStack(spacing: 32) {
            SpinningWait(isUpdating: $isUpdating, size: 8)
            SpinningWait(isUpdating: $isUpdating, size: 12)
            SpinningWait(isUpdating: $isUpdating, size: 16)
            SpinningWait(isUpdating: $isUpdating, size: 22)
            
            Button(isUpdating ? "stop" : "start") {
                self.isUpdating.toggle()
            }
        }
    }
}

struct SpinningWait_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            SpinningWaitTesting()
        }
    }
}
