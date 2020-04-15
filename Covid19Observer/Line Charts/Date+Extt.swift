//
//  Date+Extt.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}
