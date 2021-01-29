//
//  Deviation.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Variation: Codable, Hashable {
    var type: HistoryType
    var deviations: [Deviation]
}

struct Deviation: Codable, Hashable {
    var id = UUID()
    
    var country: String
    var avg, last: Double
    
    //    var changePercentage: Double {
    //        guard avg == 0 else { return 0 }
    //
    //        return last / avg - 1
    //    }
}
