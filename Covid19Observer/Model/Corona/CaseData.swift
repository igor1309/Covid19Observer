//
//  CaseData.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseData: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    
    var confirmed: Int
    var recovered: Int
    var deaths: Int
}

extension CaseData {
    //  Percentages calculations and properties for Views: …Str: String
    
    var confirmedStr: String { confirmed.formattedGrouped }
    var deathsStr: String { deaths.formattedGrouped }
    
    ///  `Case Fatality Rate`
    var cfr: Double { confirmed == 0 ? 0 : Double(deaths) / Double(confirmed) }
    var cfrStr: String { cfr.formattedPercentageWithDecimals }
}
