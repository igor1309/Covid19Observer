//
//  TimePeriod.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 01.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

enum TimePeriod: String, CaseIterable {
    //    #if debug
    case minute = "1min"
    case quarterHour = "1/4h"
    //    #endif
    case halfHour = "1/2h"
    case oneHour = "1h"
    case twoHours = "2h"
    case threeHours = "3h"
    
    var id: String { rawValue }
    
    var period: TimeInterval {
        switch self {
        //            #if debug
        case .minute:
            return 1 * 60
        case .quarterHour:
            return 15 * 60
        //            #endif
        case .halfHour:
            return 30 * 60
        case .oneHour:
            return 60 * 60
        case .twoHours:
            return 2 * 60 * 60
        case .threeHours:
            return 3 * 60 * 60
        }
    }
}
