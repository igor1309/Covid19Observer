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
    var newConfirmed: Int
    var newConfirmedStr: String
    var currentConfirmed: Int
    var currentConfirmedStr: String
    var deaths: Int
    var deathsStr: String
    var cfr: Double
    var cfrStr: String
}


enum CaseType: String, CaseIterable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
}


enum CaseDataType: String, CaseIterable {
    case confirmed = "Confirmed"
    case new = "Conf. New"
    case current = "Current"
    case deaths = "Deaths"
    case cfr = "CFR"
    
    var id: String { rawValue }
}
