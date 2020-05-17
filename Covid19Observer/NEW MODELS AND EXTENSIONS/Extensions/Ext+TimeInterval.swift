//
//  Ext+TimeInterval.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 15.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

extension TimeInterval {
    public var hours: String {
        let components = DateComponents(second: Int(self))

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour]
        return formatter.string(from: components) ?? "n/a"
    }
}
