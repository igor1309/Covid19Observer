//
//  CoronaDataTypes.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 24.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum CurrentType: String, CaseIterable, Codable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
}

enum HistoryType: String, CaseIterable, Codable {
    case confirmed = "Confirmed"
    case deaths = "Deaths"
    
    var id: String { rawValue }
}
