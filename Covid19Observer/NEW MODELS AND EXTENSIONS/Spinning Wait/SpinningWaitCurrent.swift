//
//  SpinningWaitCurrent.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SpinningWaitCurrent: View {
    @EnvironmentObject var store: Store
    @State private var isUpdating = false
    
    var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: 16, dash: [3, 1]))
            .fill(AngularGradient(
                gradient: Gradient(colors: [Color.yellow, .pink, .green, .orange]),
                center: .center))
            .frame(width: 12, height: 12)
            .rotationEffect(.degrees(isUpdating ? 360 : 0))
            .animation(isUpdating
                ? Animation.linear(duration: 2.1).repeatForever(autoreverses: false)
                : .default)
            .onReceive(store.$currentIsUpdating) {
                self.isUpdating = $0
        }
    }
}

struct SpinningWaitCurrent_Previews: PreviewProvider {
    static var previews: some View {
        SpinningWaitCurrent()
    }
}
