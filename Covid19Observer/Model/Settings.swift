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
    
    @Published var isLineChartFiltered: Bool = UserDefaults.standard.bool(forKey: "isLineChartFiltered") {
        didSet {
            UserDefaults.standard.set(isLineChartFiltered, forKey: "isLineChartFiltered")
        }
    }
    
    @Published var lineChartLimit: Int {
        didSet {
            UserDefaults.standard.set(lineChartLimit, forKey: "lineChartLimit")
        }
    }

    
    init() {
        let savedInitialNumber = UserDefaults.standard.double(forKey: "initialNumber")
        if savedInitialNumber == 0 {
            initialNumber = 5
        } else {
            initialNumber = savedInitialNumber
        }

        let savedLineChartLimit = UserDefaults.standard.integer(forKey: "lineChartLimit")
        if savedLineChartLimit == 0 {
            lineChartLimit = 100
        } else {
            lineChartLimit = savedLineChartLimit
        }
    }
}
