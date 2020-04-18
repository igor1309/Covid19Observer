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
    
    var lineChartLimit: Int {
        switch selectedDataKind {
        case .cfr:
            return 0
        case .deathsTotal, .deathsDaily:
            return isLineChartFiltered ? deathsLineChartLimit : 0
        default:
            return isLineChartFiltered ? confirmedLineChartLimit : 0
        }
    }
    
    @Published var appendCurrent: Bool = UserDefaults.standard.bool(forKey: "appendCurrent") {
        didSet {
            UserDefaults.standard.set(appendCurrent, forKey: "appendCurrent")
        }
    }
    
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
    
    @Published var confirmedLineChartLimit: Int {
        didSet {
            UserDefaults.standard.set(confirmedLineChartLimit, forKey: "confirmedLineChartLimit")
        }
    }

    @Published var deathsLineChartLimit: Int {
        didSet {
            UserDefaults.standard.set(deathsLineChartLimit, forKey: "deathsLineChartLimit")
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
        
        let savedConfirmedLineChartLimit = UserDefaults.standard.integer(forKey: "confirmedLineChartLimit")
        if savedConfirmedLineChartLimit == 0 {
            confirmedLineChartLimit = 50
        } else {
            confirmedLineChartLimit = savedConfirmedLineChartLimit
        }
        
        let savedDeathsLineChartLimit = UserDefaults.standard.integer(forKey: "deathsLineChartLimit")
        if savedDeathsLineChartLimit == 0 {
            deathsLineChartLimit = 10
        } else {
            deathsLineChartLimit = savedDeathsLineChartLimit
        }
        
        let selectedDataKindID = UserDefaults.standard.string(forKey: "selectedDataKind") ?? ""
        if selectedDataKindID.isEmpty {
            selectedDataKind = .confirmedDaily
        } else {
            selectedDataKind = DataKind(rawValue: selectedDataKindID) ?? .confirmedDaily
        }
    }
}
