//
//  Historical.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Historical: Codable, Hashable {
    /// нужно суммировать данные по провинциям в следующих странах
    static let countriesWithRegions = ["Australia", "Canada", "China", "Denmark", "France", "Netherlands", "United Kingdom"]
    
    let type: HistoryType
    
    //  Data
    
    /// значения на оси X (время как String в формате dd.MM.yyyy)
    private(set) var xLabels = [String]()
    private(set) var countryRows = [CountryRow]()
    
    private(set) var allCountriesTotals = [Int]()
    private(set) var allCountriesDailyChange = [Int]()
    
    //  Metadata
    
    private(set) var syncDate: Date// = .distantPast
}

extension Historical {
    init(type: HistoryType, xLabels: [String], countryRows: [CountryRow]) {
        
        let allCountriesTotals: [Int] = {
            guard countryRows.count > 0 else { return [] }
            
            var totals = Array(repeating: 0, count: countryRows[0].series.count)
            for row in countryRows {
                for i in 0..<row.series.count {
                    totals[i] += row.series[i]
                }
            }
            
            return totals
        }()
        
        let allCountriesDailyChange: [Int] = {
            guard allCountriesTotals.count > 1 else { return [] }
            
            var daily = [Int]()
            for i in 1..<allCountriesTotals.count {
                daily.append(allCountriesTotals[i] - allCountriesTotals[i-1])
            }
            
            return daily
            
        }()
        
        self.init(type: type,
                  xLabels: xLabels,
                  countryRows: countryRows,
                  allCountriesTotals: allCountriesTotals,
                  allCountriesDailyChange: allCountriesDailyChange,
//                  syncStatus: countryRows.isNotEmpty,
                  syncDate: Date()
        )
    }
}

//  MARK: Functions
extension Historical {
    
    func dailyChange(for country: String) -> [Int] {
        let countryData = series(for: country)
        guard countryData.count > 1 else { return [] }
        
        var change = [Int]()
        
        for i in 1..<countryData.count {
            change.append(countryData[i] - countryData[i-1])
        }
        
        return change
    }
    
    //  MARK: FIX THIS
    //  НЕ СОБИРАЕТ POINTS!!
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
    
    func series(forRegion region: String) -> [Int] {
        let filtered = countryRows.filter { ($0.provinceState + $0.countryRegion) == region }
        if filtered.isEmpty {
            return []
        } else {
            let series = filtered[0].series
            /// если последний элемент равен нулю, то вероятнее всего нет данных на последний день
            if series.last! == 0 {
                return series.dropLast()
            } else {
                return series
            }
        }
    }
    
    func last(for country: String) -> Int {
        return series(for: country).last ?? 0
    }
    
    func previous(for country: String) -> Int {
        return series(for: country).dropLast().last ?? 0
    }
}

//  MARK: TESTING
extension Historical {
    mutating func test() {
        switch self.type {
        case .confirmed:
            xLabels += ["20"]
            countryRows += [CountryRow(provinceState: "", countryRegion: "Russia", points: [:], series: [8_000,10_000])]
        default:
            xLabels += ["1"]
            countryRows += [CountryRow(provinceState: "", countryRegion: "Russia", points: [:], series: [1_000,2_000])]
        }
    }
}
