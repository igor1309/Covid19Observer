//
//  DataSet.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftUI

struct DataSet {
    var name: String
    var xLabels: [String]
    var series: [DataKind: [CGFloat]]
    
    /// Filter (remove) first elements of the array in series that are less than limit
    func chartSource(for dataKind: DataKind, limitFirstBy limit: CGFloat) -> (xLabels: [String], yValues: [CGFloat]) {
        
        guard let yValues = series[dataKind] else { return ([], []) }
        
        guard limit > yValues.min()! else { return (xLabels, yValues) }
        
        var xLabelsCopy = xLabels
        var yValuesCopy = yValues
        while yValues.isNotEmpty {
            if yValuesCopy.first! < limit {
                xLabelsCopy = Array(xLabelsCopy.dropFirst())
                yValuesCopy = Array(yValuesCopy.dropFirst())
            } else {
                break
            }
        }
        
        return (Array(xLabelsCopy), Array(yValuesCopy))
    }
    
    init() {
        self.name = ""
        self.xLabels = []
        self.series = [:]
    }
    
    init(name: String, xLabels: [String], series: [DataKind: [CGFloat]]) {
        self.name = name
        self.xLabels = xLabels
        self.series = series
    }
}

extension DataSet {
    init(country: String, confirmed: Historical, deaths: Historical) {
        let xLabels = confirmed.xLabels
        
        var series = [DataKind: [CGFloat]]()
        
        //  MARK: negative values crash charts!!!
        
        let confirmedTotal = confirmed.series(for: country)
            .map { CGFloat($0) }
        series[.confirmedTotal] = confirmedTotal
            .filter { $0 >= 0 }
        
        series[.confirmedDaily] = confirmed.dailyChange(for: country)
            .filter { $0 >= 0 }
            .map { CGFloat($0) }
        
        let deathsTotal = deaths.series(for: country)
            .map { CGFloat($0) }
        series[.deathsTotal] = deathsTotal
            .filter { $0 >= 0 }
        
        series[.deathsDaily] = deaths.dailyChange(for: country)
            .filter { $0 >= 0 }
            .map { CGFloat($0) }
        
        //  MARK: - FIX THIS!!
        //  нужно прицепить scan!!
        series[.cfr] = zip(confirmedTotal, deathsTotal).map { $0 == 0 ? 0 : $1 / $0 }
        
        self.init(name: country, xLabels: xLabels, series: series)
    }
}
