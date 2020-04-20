//
//  DataKind.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum DataKind: String, CaseIterable, Codable {
    case confirmedTotal = "Confirmed Cases"
    case confirmedDaily = "Confirmed Cases Daily"
    case deathsTotal = "Deaths"
    case deathsDaily = "Deaths Daily"
    case cfr = "Case Fatality Rate"
    
    var id: String { rawValue }
    
    var abbreviation: String {
        switch self {
        case .confirmedTotal:
            return "Conf."
        case .confirmedDaily:
            return "Conf.D"
        case .deathsTotal:
            return "Deaths"
        case .deathsDaily:
            return "Deaths.D"
        case .cfr:
            return "CFR"
        }
    }
}
