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
struct History {
    struct ShortCaseRow: Identifiable {
        var id: String { countryRegion }
        var provinceState, countryRegion: String
        //        var points: [Date: Int]
        var series: [Int]
    }
    
    static let primeCountries = ["Russia", "Italy", "France", "Germany", "Finland"]
    
    var table: [[String]] = []
    var rows: [ShortCaseRow] = []
    
    var provinceStateCountryRegions: [String] {
        Array(rows.map { $0.countryRegion + ($0.provinceState == "" ? "" : ", " + $0.provinceState) }
            .dropFirst())
            .removingDuplicates()
            .sorted()
    }
    
    var countryRegions: [String] {
        Array(rows.map { $0.countryRegion }
            .dropFirst())
            .removingDuplicates()
            .sorted()
    }
    
    private init(table: [[String]], rows: [ShortCaseRow]) {
        self.table = table
        self.rows = rows
    }
    
    init(from casesStr: String) {
        var table: [[String]] = []
        var rows: [ShortCaseRow] = []
        if casesStr.isNotEmpty {
            table = getTable(from: casesStr)
            rows = getRows(from: table)
        }
        self = History(table: table, rows: rows)
    }
    
    func series(for country: String) -> [Int] {
        let filtered = rows.filter { $0.countryRegion == country }
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
    
    private func getTable(from cases: String) -> [[String]] {
        /// returns first quoted text and drops this quote from passed string
        func parseQuotes(stringToParse: inout String) -> [String] {
            if stringToParse.first == "\"" {
                let lastIndex = stringToParse.index(before: stringToParse.endIndex)
                let secondQuoteIndex = String(stringToParse.dropFirst()).firstIndex(of: "\"")!
                
                let prefix = String(stringToParse.prefix(through: secondQuoteIndex))
                stringToParse = String(stringToParse[secondQuoteIndex..<lastIndex].dropFirst(3))
                
                return [prefix.replacingOccurrences(of: "\"", with: "")]
            } else {
                return []
            }
        }
        
        let rows = cases.components(separatedBy: "\n")
        var table = [[String]]()
        for i in 0..<rows.count {
            var stringToParse = rows[i]
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
    
    private func getRows(from table: [[String]]) -> [ShortCaseRow]{
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
    
    /// date as String in format m/d/yy
    private func dateFromStr(_ str: String) -> Date {
        let strComponents = str.components(separatedBy: "/")
        let month = Int(strComponents[0])
        let day = Int(strComponents[1])
        let year = 2000 + (Int(strComponents[2]) ?? 0)
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }
}
