//
//  Settings.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Country: Hashable {
    var name: String
    var iso2: String
}

final class Settings: ObservableObject {
    
    @Published var primeCountries: [Country] {
        didSet {
            UserDefaults.standard.set(primeCountries, forKey: "primeCountries")
        }
    }
    
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

    @Published var selectedDataKind: DataKind {
        didSet {
            UserDefaults.standard.set(selectedDataKind.id, forKey: "selectedDataKind")
        }
    }
    
    init() {
        let countries: [Country] = UserDefaults.standard.array(forKey: "primeCountries") as? [Country] ?? []
        if countries.isEmpty {
            primeCountries = [Country(name: "Russia", iso2: "RU"),
                              Country(name: "US", iso2: "US"),
                              Country(name: "Italy", iso2: "IT"),
                              Country(name: "Germany", iso2: "DE"),
                              Country(name: "France", iso2: "FR"),
                              Country(name: "Finland", iso2: "FI"),
                              Country(name: "Spain", iso2: "ES"),
                              Country(name: "China", iso2: "CN")]
        } else {
            primeCountries = countries
        }
        
        let savedInitialNumber = UserDefaults.standard.double(forKey: "initialNumber")
        if savedInitialNumber == 0 {
            initialNumber = 5
        } else {
            initialNumber = savedInitialNumber
        }
        
        let savedLineChartLimit = UserDefaults.standard.integer(forKey: "lineChartLimit")
        if savedLineChartLimit == 0 {
            lineChartLimit = 50
        } else {
            lineChartLimit = savedLineChartLimit
        }
        
        let selectedDataKindID = UserDefaults.standard.string(forKey: "selectedDataKind") ?? ""
        if selectedDataKindID.isEmpty {
            selectedDataKind = .confirmedDaily
        } else {
            selectedDataKind = DataKind(rawValue: selectedDataKindID) ?? .confirmedDaily
        }
    }
}
