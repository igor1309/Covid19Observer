//
//  DoublingModel.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum DoublingModel {
    static let initialNumbers: [Double] = [1, 5, 10, 20, 50, 100]
    static let doublingTimes: [Double] = [2, 3, 4, 5, 6, 7, 10, 14]
    static let weeklyPeriods: [Double] = [1, 2, 3, 4, 5, 6]
    
    /// https://en.wikipedia.org/wiki/Doubling_time
    private static func number(initialNumber: Double, weekNo: Double, doublingTime: Double) -> Double {
        return initialNumber * pow(2, weekNo * 7 / doublingTime)
    }
    
    static func rowHeaders() -> [String] {
        var headers = [""]
        for i in 1 ... weeklyPeriods.count {
            headers.append("Week \(i)")
        }
        return headers
    }
    
    static func DoublingCells(initialNumber: Double) -> [[String]] {
        var cells = [[String]]()
        
        var row = [String]()
        for i in 0 ..< doublingTimes.count {
            row.append(doublingTimes[i].formattedGrouped)
        }
        cells.append(row)
        
        for i in 0 ..< weeklyPeriods.count {
            var row = [String]()
            for j in 0 ..< doublingTimes.count {
                //                row.append("i\(i)-j\(j)")
                row.append(number(initialNumber: initialNumber,
                                  weekNo: weeklyPeriods[i],
                                  doublingTime: doublingTimes[j])
                    .formattedGrouped)
            }
            cells.append(row)
        }
        return cells
    }
}
