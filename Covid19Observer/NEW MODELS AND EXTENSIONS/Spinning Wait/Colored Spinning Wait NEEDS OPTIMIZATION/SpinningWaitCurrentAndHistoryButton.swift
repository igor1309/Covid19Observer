//
//  SpinningWaitCurrentAndHistoryButton.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

struct SpinningWaitCurrentAndHistoryButton: View {
    @EnvironmentObject var store: Store
    var size: CGFloat = 12
    
    var body: some View {
        HStack(spacing: 16) {
            SpinningWaitCurrentAndHistory(size: size)
            
            Button(action: {
                self.store.fetchCurrent()
            }) {
                Text("update data").fixedSize()
            }
        }
        .padding(.top, 32)
    }
}

struct SpinningWaitCurrentAndHistoryButton_Previews: PreviewProvider {
    static var previews: some View {
        SpinningWaitCurrentAndHistoryButton()
    }
}
