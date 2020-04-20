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
