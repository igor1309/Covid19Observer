//
//  ChartOptions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftUI

struct ChartOptions: Codable {
    var dataKind: DataKind = .confirmedDaily
    
    var appendCurrent: Bool = false
    
    var isFiltered: Bool = false
    var confirmedLimit: CGFloat = 50
    var deathsLimit: CGFloat = 10
    var cfrLimit: CGFloat = 1 / 100 / 100
    
    var lineChartLimit: CGFloat {
        switch dataKind {
        case .cfr:
            return isFiltered ? cfrLimit : 0
        case .deathsTotal, .deathsDaily:
            return isFiltered ? deathsLimit : 0
        default:
            return isFiltered ? confirmedLimit : 0
        }
    }
}
