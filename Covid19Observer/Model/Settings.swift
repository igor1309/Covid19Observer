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

    @Published var chartOptions: ChartOptions {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(chartOptions) {
                UserDefaults.standard.set(encoded, forKey: "chartOptions")
            }
        }
    }
    
    init() {
        
        /// https://www.hackingwithswift.com/example-code/system/how-to-load-and-save-a-struct-in-userdefaults-using-codable
        if let savedOptions = UserDefaults.standard.object(forKey: "chartOptions") as? Data {
            let decoder = JSONDecoder()
            if let loadedOptions = try? decoder.decode(ChartOptions.self, from: savedOptions) {
                chartOptions = loadedOptions
            } else {
                chartOptions = ChartOptions()
            }
        } else {
            chartOptions = ChartOptions()
        }
        
        
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
    }
}
