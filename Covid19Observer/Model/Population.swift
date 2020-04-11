//
//  Population.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

//  Data Source    World Development Indicators

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let population = try? newJSONDecoder().decode(Population.self, from: jsonData)

import Foundation

typealias Population = [PopulationElement]

// MARK: PopulationElement
struct PopulationElement: Codable, Hashable, Identifiable {
    let countryName, countryCode: String
    private let the2018: Int
    
    var id: String { countryCode }
    var population: Int { the2018 }
    
    enum CodingKeys: String, CodingKey {
        case the2018 = "2018"
        case countryName = "Country Name"
        case countryCode = "Country Code"
    }
}
