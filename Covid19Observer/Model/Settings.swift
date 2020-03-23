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
    
    @Published var initialNumber = UserDefaults.standard.double(forKey: "initialNumber") {
        didSet {
            UserDefaults.standard.set(initialNumber, forKey: "initialNumber")
        }
    }
}
