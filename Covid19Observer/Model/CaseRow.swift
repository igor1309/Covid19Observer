//
//  CaseRow.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseRow: Codable, Identifiable {
    var id: String { provinceState + "/" + countryRegion }
    
    var provinceState, countryRegion: String
    var name: String { provinceState + "/" + countryRegion }
    var points: [Date: Int]
    var series: [Int]
}
