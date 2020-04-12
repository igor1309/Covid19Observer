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
    var confirmed: Int
    var confirmedStr: String
    var confirmedNew: Int
    var confirmedNewStr: String
    var confirmedCurrent: Int
    var confirmedCurrentStr: String
    var deaths: Int
    var deathsStr: String
    var deathsNew: Int
    var deathsNewStr: String
    var deathsCurrent: Int
    var deathsCurrentStr: String
    var cfr: Double
    var cfrStr: String
}


enum CaseType: String, CaseIterable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
}


enum DataKind: String, CaseIterable {
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
            return .systemOrange
        case .current:
            return .systemPurple
        case .deaths:
            return .systemRed
        case .cfr:
            return .systemTeal
        }
    }
}
