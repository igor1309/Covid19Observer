//
//  CaseData.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseData: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var confirmed: Int
    var confirmedStr: String
    var deaths: Int
    var deathsStr: String
    var cfr: Double
    var cfrStr: String
}
