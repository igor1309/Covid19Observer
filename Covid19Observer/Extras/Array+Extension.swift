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
    
    /// Filter (remove) first elements of the array that are less than limit
    /// - Parameter limit: limit
    /// - Returns: filteredarray
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
    
    /// Filter (remove) first elements of the array that are less than limit
    /// - Parameter limit: limit
    /// - Returns: filtered array
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
