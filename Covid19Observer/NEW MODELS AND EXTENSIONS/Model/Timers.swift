//
//  Timers.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Combine
import SwiftUI

/// based on https://stackoverflow.com/questions/61471559/swift-combine-how-can-i-create-a-reusable-publishers-map-to-connect-to-multiple
class Timers: ObservableObject {
    @Published private(set) var thirtySeconds = ""
    
    let thirtySecondsTimer = Timer.publish(every: 3, on: .main, in: .common)
        .autoconnect()
        .eraseToAnyPublisher()
    
    init() {
        thirtySecondsTimer
            .sink { [weak self] _ in
                self?.thirtySeconds = "30"
        }
        .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}
