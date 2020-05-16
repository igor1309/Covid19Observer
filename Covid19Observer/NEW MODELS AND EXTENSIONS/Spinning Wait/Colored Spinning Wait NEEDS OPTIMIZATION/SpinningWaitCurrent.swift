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
    
    var size: CGFloat = 12
    
    var body: some View {
        SpinningWait(isUpdating: $isUpdating, size: size)
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
