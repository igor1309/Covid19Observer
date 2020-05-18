//
//  Settings.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

final class Settings: ObservableObject {
    
    @Published var selectedTab = UserDefaults.standard.integer(forKey: "selectedTab") {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }
    
    @Published var chartOptions: ChartOptions {
        didSet {
            if let encoded = try? JSONEncoder().encode(chartOptions) {
                UserDefaults.standard.set(encoded, forKey: "chartOptions")
            }
        }
    }
    
    @Published var mapOptions = MapOptions() {
        didSet {
            if let encoded = try? JSONEncoder().encode(mapOptions) {
                UserDefaults.standard.set(encoded, forKey: "mapOptions")
            }
        }
    }
    
    //  MARK: SWIFTUI/COMBINE BUG/FEATURE?? preventing @Published array changes to fire didSet
    /// solution via subscriber in init()
    @Published var primeCountries: [Country] {
        didSet {
            if let encoded = try? JSONEncoder().encode(primeCountries) {
                UserDefaults.standard.set(encoded, forKey: "primeCountries")
            }
        }
    }
    
    @Published var initialDoublingNumber: Double {
        didSet {
            UserDefaults.standard.set(initialDoublingNumber, forKey: "initialNumber")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        //        /// https://www.hackingwithswift.com/example-code/system/how-to-load-and-save-a-struct-in-userdefaults-using-codable
        //        if let savedOptions = UserDefaults.standard.object(forKey: "chartOptions") as? Data {
        //            if let loadedOptions = try? JSONDecoder().decode(ChartOptions.self, from: savedOptions) {
        //                chartOptions = loadedOptions
        //            } else {
        //                chartOptions = ChartOptions()
        //            }
        //        } else {
        //            chartOptions = ChartOptions()
        //        }
        chartOptions = UserDefaults.standard.getObj(forKey: "chartOptions", empty: ChartOptions())
        
        let savedInitialNumber = UserDefaults.standard.double(forKey: "initialNumber")
        if savedInitialNumber == 0 {
            initialDoublingNumber = 5
        } else {
            initialDoublingNumber = savedInitialNumber
        }
        
        
        let countries = [Country(name: "Russia", iso2: "RU"),
                         Country(name: "US", iso2: "US"),
                         Country(name: "Italy", iso2: "IT"),
                         Country(name: "Germany", iso2: "DE"),
                         Country(name: "France", iso2: "FR"),
                         Country(name: "Finland", iso2: "FI"),
                         Country(name: "Spain", iso2: "ES"),
                         Country(name: "China", iso2: "CN")]
        primeCountries = UserDefaults.standard.getObj(forKey: "primeCountries", empty: countries)
        
        /// https://www.hackingwithswift.com/forums/swiftui/triggering-didset-of-a-propertyobserver-confusion/312
        /// Published wrapper dosn't track changes inside array
        self.$primeCountries
            .sink { countries in
                if let encoded = try? JSONEncoder().encode(countries) {
                    UserDefaults.standard.set(encoded, forKey: "primeCountries")
                }
        }
        .store(in: &cancellables)
    }
}
