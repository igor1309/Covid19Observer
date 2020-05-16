//
//  DataKind.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

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
            return "C.Dly"
        case .deathsTotal:
            return "Deaths"
        case .deathsDaily:
            return "D.Dly"
        case .cfr:
            return "CFR"
        }
    }
    
    var color: Color {
        switch self {
        case .confirmedTotal:
            return .confirmed//.systemYellow
        case .confirmedDaily:
            return .confirmed//.systemYellow
        case .deathsTotal:
            return .deaths//.systemRed
        case .deathsDaily:
            return .deaths//.systemRed
        case .cfr:
            return .cfr//.systemTeal
        }
    }
}
