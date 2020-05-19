//
//  DataSet.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct DataSet {
    let name: String
    let xLabels: [String]
    let series: [DataKind: [Int]]
}
