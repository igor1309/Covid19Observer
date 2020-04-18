//
//  ChartOptions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct ChartOptions: Codable {
    var dataKind: DataKind = .confirmedDaily
    
    var isFiltered: Bool = false
    var confirmedLimit: Int = 50
    var deathsLimit: Int = 10
    
    var lineChartLimit: Int {
        switch dataKind {
        case .cfr:
            return 0
        case .deathsTotal, .deathsDaily:
            return isFiltered ? deathsLimit : 0
        default:
            return isFiltered ? confirmedLimit : 0
        }
    }
}
