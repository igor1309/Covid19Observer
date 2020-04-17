//
//  Range+Ext.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

extension Range where Bound: Numeric {
    var distance: Bound {
        return upperBound - lowerBound
    }
}
