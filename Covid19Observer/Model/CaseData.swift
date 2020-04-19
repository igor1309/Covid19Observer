//
//  CaseData.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseData: Identifiable, Hashable {
    var id = UUID()
    var name: String
    
    ///  `Confirmed Cases`
    
    var confirmed: Int
    var confirmedNew: Int
    var confirmedCurrent: Int
    
    ///  `Recovered`
    
    // MARK: FINISH THIS
    var recovered: Int
    
    ///  `Deaths`
    
    var deaths: Int
    var deathsNew: Int
    var deathsCurrent: Int
}

extension CaseData {
    //  Percentages calculations and properties for Views: …Str: String
    
    ///  `Confirmed Cases`
    
    var confirmedStr: String { confirmed.formattedGrouped }
    var confirmedNewStr: String { confirmedNew.formattedGrouped }
    var confirmedCurrentStr: String { confirmedCurrent.formattedGrouped }

    ///  `Deaths`

    var deathsStr: String { deaths.formattedGrouped }
    var deathsNewStr: String { deathsNew.formattedGrouped }
    var deathsCurrentStr: String { deathsCurrent.formattedGrouped }

    ///  `Case Fatality Rate`
    
    var cfr: Double { confirmed == 0 ? 0 : Double(deaths) / Double(confirmed) }
    var cfrStr: String { cfr.formattedPercentageWithDecimals }
}


enum CaseType: String, CaseIterable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
}


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


enum CaseDataType: String, CaseIterable {
    case confirmed = "Confirmed Cases"
    case new = "New Confirmed"
    case current = "Current Confirmed"
    case deaths = "Deaths"
    case cfr = "Case Fatality Rate"//"CFR"
    
    var id: String { rawValue }
    
    var short: String {
        switch self {
        case .confirmed:
            return "Conf."
        case .new:
            return "New"
        case .current:
            return "Cur."
        case .deaths:
            return "Deaths"
        case .cfr:
            return "CFR"
        }
    }
    
    var color: Color {
        switch self {
        case .confirmed:
            return .systemYellow
        case .new:
            return Color("confirmed")//.systemOrange
        case .current:
            return .systemPurple
        case .deaths:
            return .systemRed
        case .cfr:
            return .systemTeal
        }
    }
}
