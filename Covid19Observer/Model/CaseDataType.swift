//
//  CaseDataType.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum CaseDataType: String, CaseIterable {
    case confirmed = "Confirmed"
    case deaths = "Deaths"
    case cfr = "CFR"
    
    var id: String { rawValue }
}
