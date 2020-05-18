//
//  UpdateSection.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct UpdateSection: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        Section(header: Text("Update".uppercased()),
                footer: Text("Data by John Hopkins.")
        ) {
            Button(action: {
                self.store.fetchCurrent()
            }) {
                HStack(spacing: 16) {
                    SpinningArrowsWithSubscriberButton(
                        title: nil, publisher: store.$currentIsUpdating.eraseToAnyPublisher()
                    ) {
                        self.store.fetchCurrent()
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.currentSyncInfo.text)
                            .foregroundColor(store.currentSyncInfo.color)
                        
                        Text(store.currentSyncInfo.status)
                            .foregroundColor(.tertiary)
                    }
                }
            }
            
            Button(action: {
                self.store.fetchHistory()
            }) {
                HStack(spacing: 16) {
                    SpinningArrowsWithSubscriberButton(
                        title: nil, publisher: store.$historyIsUpdating.eraseToAnyPublisher()
                    ) {
                        self.store.fetchHistory()
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.historySyncInfo.text)
                            .foregroundColor(store.historySyncInfo.color)
                        
                        Text(store.historySyncInfo.status)
                            .foregroundColor(.tertiary)
                    }
                }
            }
        }
    }
}

struct UpdateSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                UpdateSection()
                    .environmentObject(Store())
            }
        }
        .environment(\.colorScheme, .dark)
    }
}
