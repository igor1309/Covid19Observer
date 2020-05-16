//
//  SpinningWaitCurrentButton.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SpinningWaitCurrentButton: View {
    @EnvironmentObject var store: Store
    var size: CGFloat = 12
    
    var body: some View {
        HStack(spacing: 16) {
            SpinningWaitCurrent(size: size)
            
            Button(action: {
                self.store.fetchCurrent()
            }) {
                Text("update data").fixedSize()
            }
        }
        .padding(.top, 32)
    }
}

struct SpinningWaitCurrentButton_Previews: PreviewProvider {
    static var previews: some View {
        SpinningWaitCurrentButton()
    }
}
