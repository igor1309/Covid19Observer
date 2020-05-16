//
//  Convertor.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

enum Convertor {
    
    //  MARK: - THERE IS A LOT TO OPTIMIZE!!!
    static func deviations(from countryRows: [CountryRow], type: HistoryType, threshold: CGFloat) -> Variation {
        
        func series(for country: String) -> [Int] {
            
            guard countryRows.count > 0 else { return [] }
            
            var filteredRow: CountryRow
            
            if History.countriesWithRegions.contains(country) {
                
                //  собрать все строки с этой страной в одну
                //  и заменить блок стран с провинциями этой страны на эту одну строку
                
                let rowsForCountry = countryRows.filter { $0.countryRegion == country }
                
                var series: [Int]
                series = []
                
                //  пройтись по всем столбцам
                for i in 0 ..< countryRows[0].series.count {
                    var s = 0
                    
                    //  и собрать суммы строк
                    for row in rowsForCountry {
                        
                        s += row.series[i]
                        
                    }
                    series.append(s)
                }
                //  MARK: FIX THIS
                //  НЕ СОБИРАЕТ POINTS!!
                filteredRow = CountryRow(provinceState: "", countryRegion: country, points: [:], series: series)
                
            } else {
                
                //  если страна без провинций, то по ней данные только в одной строке
                let filteredRows = countryRows.filter { $0.countryRegion == country }
                if filteredRows.isNotEmpty {
                    filteredRow = filteredRows[0]
                } else {
                    filteredRow = CountryRow(provinceState: "", countryRegion: "", points: [:], series: [])
                }
            }
            
            if filteredRow.series.isEmpty {
                return []
            } else {
                
                //  MARK: FIX THIS
                //  нужна проверка по дате а не тупой отброс последнего значения
                //  https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data
                //  All timestamps are in UTC (GMT+0)
                /// если последний элемент равен нулю, то вероятнее всего нет данных на последний день
                let series = filteredRow.series
                //            if series.last! == 0 {
                //                return series.dropLast()
                //            } else {
                return series
                //            }
            }
            
        }

        
        guard countryRows.isNotEmpty else {
            print("returning empty deviations since countryRows are empty")
            return Variation(type: type, deviations: [])
        }
        
        var devs = [Deviation]()
        var visitedCountries = [String]()
        
        for countryRow in countryRows {
            
            let country = countryRow.countryRegion
            
            //  get daily change for last 7 days (or less if dataset is smaller)
            
            let last8days: [Int]
            
            /// страна с провинциями?
            if History.countriesWithRegions.contains(country) {
                /// если страна с провинциями, то собрать только если еще не собирал
                if visitedCountries.contains(country) {
                    /// уже собрано, переходить к след
                    continue
                } else {
                    /// отметить собранной
                    visitedCountries.append(country)
                    /// собрать по всем провинциям
                    last8days = Array(series(for: country).suffix(8))
                }
            } else {
                last8days = Array(countryRow.series.suffix(8))
            }
            
            guard last8days.count > 0  else { continue }
            
            var dailyChange = [Int]()
            
            for i in 1..<last8days.count {
                let change = last8days[i] - last8days[i-1]
                dailyChange.append(change)
            }
            
            //  calculate avg and compare with last
            
            let avg = dailyChange.reduce(CGFloat(0)) { $0 + CGFloat($1) } / CGFloat(dailyChange.count)
            
            let last = CGFloat(dailyChange.last!)
            
            let percent: CGFloat = 50/100
            let isSignificantlyChanged = last >= avg * (1 + percent) || last <= avg * (1 - percent)
            let isGreaterThanThreshold = last >= threshold || avg >= threshold
            
            if isSignificantlyChanged && isGreaterThanThreshold {
                devs.append(Deviation(country: country, avg: Double(avg), last: Double(last)))
            }
        }

        return Variation(type: type, deviations: devs)
    }
}
