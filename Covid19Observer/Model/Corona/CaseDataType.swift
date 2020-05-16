//
//  CaseDataType.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

enum CaseDataType: String, CaseIterable {
    case confirmed = "Confirmed Cases"
    case new = "New Confirmed Cases"
    case current = "Current Confirmed Cases"
    case deaths = "Deaths"
    case cfr = "Case Fatality Rate"//"CFR"
    
    var id: String { rawValue }
    
    var abbreviation: String {
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
            return .confirmed//.systemYellow
        case .new:
            return .new//.systemOrange
        case .current:
            return .current//.systemPurple
        case .deaths:
            return .deaths//.systemRed
        case .cfr:
            return .cfr//.systemTeal
        }
    }
}
