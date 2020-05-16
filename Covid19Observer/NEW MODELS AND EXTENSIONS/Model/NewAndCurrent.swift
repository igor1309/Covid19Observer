//
//  NewAndCurrent.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct NewAndCurrent: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    
    ///  `Confirmed Cases`
    
    var confirmedNew: Int
    var confirmedCurrent: Int

    ///  `Deaths`
    
    var deathsNew: Int
    var deathsCurrent: Int
}

extension NewAndCurrent {
    //  Percentages calculations and properties for Views: …Str: String
    
    ///  `Confirmed Cases`
    
    var confirmedNewStr: String { confirmedNew.formattedGrouped }
    var confirmedCurrentStr: String { confirmedCurrent.formattedGrouped }

    ///  `Deaths`

    var deathsNewStr: String { deathsNew.formattedGrouped }
    var deathsCurrentStr: String { deathsCurrent.formattedGrouped }
}

