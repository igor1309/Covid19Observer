//
//  Settings.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

final class Settings: ObservableObject {
    
    @Published var selectedTab = UserDefaults.standard.integer(forKey: "selectedTab") {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }
    
    @Published var initialNumber: Double {
        didSet {
            UserDefaults.standard.set(initialNumber, forKey: "initialNumber")
        }
    }
    
    init() {
        let savedInitialNumber = UserDefaults.standard.double(forKey: "initialNumber")
        if savedInitialNumber == 0 {
            initialNumber = 5
        } else {
            initialNumber = savedInitialNumber
        }
    }
}
