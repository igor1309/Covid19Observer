//
//  CaseType.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum CaseType: String, CaseIterable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
}

