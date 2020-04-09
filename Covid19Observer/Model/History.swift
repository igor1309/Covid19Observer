//
//  Cases.swift
//  Doubling
//
//  Created by Igor Malyarov on 17.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

/// <#Description#>
struct History: Codable {
    
    struct ShortCaseRow: Codable, Identifiable {
        var id: String { provinceState + "/" + countryRegion }
        
        var provinceState, countryRegion: String
        //        var points: [Date: Int]
        var name: String { provinceState + "/" + countryRegion }
        var series: [Int]
    }
    
    private(set) var rows: [ShortCaseRow] = []
    
    init(from casesCSV: String) {
        guard casesCSV.isNotEmpty else {
            self.rows = []
            return
        }
        
        var table: [[String]] = []
        var rows: [ShortCaseRow] = []
        
        /// remove any special characters in a string
        table = parseCVStoTable(
            from: casesCSV
                .components(separatedBy: CharacterSet.symbols)
                .joined(separator: ""))
        rows = getRows(from: table)
        
        self.rows = rows
    }
    
    var allCountriesTotals: [Int] {
        guard rows.count > 0 else { return [] }
        
        var totals = Array(repeating: 0, count: rows[0].series.count)
        
        for row in rows {
            for i in 0..<row.series.count {
                totals[i] += row.series[i]
            }
        }
        
        return totals
    }
    
    var allCountriesDailyChange: [Int] {
        guard allCountriesTotals.count > 1 else { return [] }
        
        var daily = [Int]()
        
        for i in 1..<allCountriesTotals.count {
            daily.append(allCountriesTotals[i] - allCountriesTotals[i-1])
        }
        
        return daily
        
    }
    
    func dailyChange(for country: String) -> [Int] {
        let countryData = series(for: country)
        guard countryData.count > 1 else { return [] }
        
        var change = [Int]()
        
        for i in 1..<countryData.count {
            change.append(countryData[i] - countryData[i-1])
        }
        
        return change
    }
    
    func series(for country: String) -> [Int] {
        
        guard rows.count > 0 else { return [] }
        
        /// нужно суммировать данные по провинциям в следующих странах
        let countriesWithRegions = ["Australia", "Canada", "China", "Denmark", "France", "Netherlands", "United Kingdom"]
        
        var filteredRow: ShortCaseRow
        
        if countriesWithRegions.contains(country) {
            
            //  собрать все строки с этой страной в одну
            //  и заменить блок стран с провинциями этой страны на эту одну строку
            
            let rowsForCountry = rows.filter { $0.countryRegion == country }
            
            var series: [Int]
            series = []
            
            //  пройтись по всем столбцам
            for i in 0 ..< rows[0].series.count {
                var s = 0
                
                //  и собрать суммы строк
                for row in rowsForCountry {
                    
                    s += row.series[i]
                    
                }
                series.append(s)
            }
            
            filteredRow = ShortCaseRow(provinceState: "", countryRegion: country, series: series)
            
        } else {
            
            //  если страна без провинций, то по ней данные только в одной строке
            let filteredRows = rows.filter { $0.countryRegion == country }
            if filteredRows.isNotEmpty {
                filteredRow = filteredRows[0]
            } else {
                filteredRow = ShortCaseRow(provinceState: "", countryRegion: "", series: [])
            }
        }
        
        if filteredRow.series.isEmpty {
            return []
        } else {
            
            //  MARK: - FIX THIS
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
        let filtered = rows.filter { ($0.provinceState + $0.countryRegion) == region }
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
    
    private func getRows(from table: [[String]]) -> [ShortCaseRow] {
        
        var shortCaseRows: [ShortCaseRow] = []
        
        for i in 0 ..< table.count {
            let row = table[i]
            let provinceState = row[0]
            let countryRegion = row[1]
            //            var points: [Date: Int] = [:]
            var series: [Int] = []
            for j in 4 ..< row.count {
                //                points[dateFromStr(table[0][j])] = Int(row[j])
                series.append(Int(row[j]) ?? 0)
            }
            shortCaseRows.append(ShortCaseRow(provinceState: provinceState, countryRegion: countryRegion, series: series))
            //            shortCaseRows.append(ShortCaseRow(countryRegion: countryRegion, points: points, series: series))
        }
        
        return shortCaseRows
    }
    
    private func parseCVStoTable(from cases: String) -> [[String]] {
        /// returns first quoted text and drops this quote from passed string
        func parseQuotes(stringToParse: inout String) -> [String] {
            if stringToParse.first == "\"" {
                let lastIndex = stringToParse.index(before: stringToParse.endIndex)
                let secondQuoteIndex = String(stringToParse.dropFirst()).firstIndex(of: "\"")!
                
                let prefix = String(stringToParse.prefix(through: secondQuoteIndex))
                stringToParse = String(stringToParse[secondQuoteIndex...lastIndex].dropFirst(3))
                
                return [prefix.replacingOccurrences(of: "\"", with: "")]
            } else {
                return []
            }
        }
        
        var rows = cases.components(separatedBy: "\n")
        /// drop last row if empty (реальная ситуация 24.03.2020)
        if rows.count > 1 && rows.last!.isEmpty {
            rows = rows.dropLast()
        }
        
        
        var table = [[String]]()
        for i in 0..<rows.count {
            /// remove any special characters in a string
            var stringToParse = rows[i].components(separatedBy: CharacterSet.symbols).joined(separator: "")
            
            var row: [String] = []
            
            /// if no Country/Region, create empty string as the first row element
            if stringToParse.first == "," {
                row += [""]
                stringToParse = String(stringToParse.dropFirst())
            }
            
            /// Province/State could be quoted text
            row += parseQuotes(stringToParse: &stringToParse)
            /// Country/Region could be quoted text
            row += parseQuotes(stringToParse: &stringToParse)
            /// other elements are numbers
            row += stringToParse.components(separatedBy: ",")
            
            table.append(row)
        }
        return table
    }
    
    /// date as String in format m/d/yy
    private func dateFromStr(_ str: String) -> Date {
        let strComponents = str.components(separatedBy: "/")
        let month = Int(strComponents[0])
        let day = Int(strComponents[1])
        let year = 2000 + (Int(strComponents[2]) ?? 0)
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }
}
