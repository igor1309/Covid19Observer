//
//  DataSet.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

struct DataSet {
    var name: String = ""
    var xLabels = [String]()
    var series = [DataKind: [Int]]()
}

extension DataSet {
    init(country: String, confirmed: Historical, deaths: Historical) {
        let xLabels = confirmed.xLabels
        
        var series = [DataKind: [Int]]()
        
        //  MARK: negative values crash charts!!!
        
        let confirmedTotal = confirmed.series(for: country)
            .filter { $0 >= 0 }
        series[.confirmedTotal] = confirmedTotal
        
        series[.confirmedDaily] = confirmed.dailyChange(for: country)
            .filter { $0 >= 0 }

        let deathsTotal = deaths.series(for: country)
            .filter { $0 >= 0 }
        series[.deathsTotal] = deathsTotal
        
        series[.deathsDaily] = deaths.dailyChange(for: country)
            .filter { $0 >= 0 }
        
        //  MARK: - FIX THIS!!
        series[.cfr] = zip(confirmedTotal, deathsTotal).map {
            Int($0 == 0 ? 0 : Double($1) / Double($0) * 10_000)
        }

        self.init(name: country, xLabels: xLabels, series: series)
    }
}
