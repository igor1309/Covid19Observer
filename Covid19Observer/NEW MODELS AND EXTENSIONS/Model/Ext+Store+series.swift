//
//  Ext+Store+series.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 15.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension Store {
    
    var allCountriesCFR: [Int] {
        let confirmed = confirmedHistory.allCountriesTotals
        let deaths = deathsHistory.allCountriesTotals
        
        guard confirmed.isNotEmpty else {
            return []
        }
        
        var allCFR = [Int]()
        for i in 0..<confirmed.count {
            //  MARK: FINISH THIS
            //  ГРАФИКЕ СТРОЯТСЯ ПО [Int] нужно переходить к CGFloat
            let cfr = confirmed[i] == 0 ? 0 : 100 * deaths[i] / confirmed[i]
            allCFR.append(cfr)
        }
        return allCFR
    }
    
    func series(for dataKind: DataKind, appendCurrent: Bool, forAllCountries: Bool = false) -> [CGFloat] {
        
        if forAllCountries {
            switch dataKind {
            case .confirmedTotal:
                return confirmedHistory.allCountriesTotals.map { CGFloat($0) }
            case .confirmedDaily:
                return confirmedHistory.allCountriesDailyChange.map { CGFloat($0) }
            case .deathsTotal:
                return deathsHistory.allCountriesTotals.map { CGFloat($0) }
            case .deathsDaily:
                return deathsHistory.allCountriesDailyChange.map { CGFloat($0) }
            case .cfr:
                return zip(confirmedHistory.allCountriesTotals, deathsHistory.allCountriesTotals).map { $0 == 0 ? 0 : CGFloat($1) / CGFloat($0) }
            }
        } else {
            var series: [Int]
            
            switch dataKind {
            case .confirmedTotal:
                series = confirmedHistory.series(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.confirmed
                    series.append(last)
                }
            case .confirmedDaily:
                series = confirmedHistory.dailyChange(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.confirmedCurrent
                    series.append(last)
                }
            case .deathsTotal:
                series = deathsHistory.series(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.deaths
                    series.append(last)
                }
            case .deathsDaily:
                series = deathsHistory.dailyChange(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.deathsCurrent
                    series.append(last)
                }
            case .cfr:
                //  MARK: FIX THIS
                //
                return allCountriesCFR.map { CGFloat($0) }
            }
            
            //  MARK: negative values crash charts
            //
            return series.filter { $0 >= 0 }.map { CGFloat($0) }
        }
    }
    
    
}
