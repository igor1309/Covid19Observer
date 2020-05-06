//
//  Date+Extensions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 03.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

extension Date {
    public var hoursMunutesTillNow: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: self, to: Date()) ?? "n/a"
    }
    
    public var hoursMunutesTillNowNice: String {
        let distance = self.distance(to: Date())
        if distance < 60 {
            return "just now"
        } else {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .brief
            formatter.allowedUnits = [.hour, .minute]
            let f = formatter.string(from: self, to: Date())
            if f == nil {
                return "n/a"
            } else {
                return f! + " ago"
            }
        }
    }
}
