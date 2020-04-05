//
//  Array+Extension.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 03.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftUI

extension Array where Element == Int {
    func filtered(limit: Int) -> Array {
        var copy = self
        while !copy.isEmpty {
            if copy[0] < limit {
                copy = Array(copy.dropFirst())
            } else {
                break
            }
        }
        return copy
    }
}

extension Array where Element == CGPoint {
    func filtered(limit: Int) -> Array {
        var copy = self
        while !copy.isEmpty {
            if copy[0].y < CGFloat(limit) {
                copy = Array(copy.dropFirst())
            } else {
                break
            }
        }
        return copy
    }
}
