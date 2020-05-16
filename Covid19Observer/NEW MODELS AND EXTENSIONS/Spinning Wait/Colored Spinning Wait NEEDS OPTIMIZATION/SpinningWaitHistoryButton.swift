//
//  SpinningWaitHistoryButton.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct SpinningWaitHistoryButton: View {
    @EnvironmentObject var store: Store
    var size: CGFloat = 12
    
    var body: some View {
        HStack(spacing: 16) {
            SpinningWaitHistory(size: size)
            
            Button(action: {
                self.store.fetchHistory()
            }) {
                Text("update data").fixedSize()
            }
        }
        .padding(.top, 32)
    }
}

struct SpinningWaitHistoryButton_Previews: PreviewProvider {
    static var previews: some View {
        SpinningWaitHistoryButton()
    }
}
