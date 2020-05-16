//
//  CSVParser.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

enum CSVParser {
    enum ParserError: Error { case general }
    
    static func parseCSVToHistory(csv: String) throws -> History {
        
        guard csv.isNotEmpty else {
            print("parseCSVToHistory got empty string to parse, throws error")
            throw ParserError.general
        }
        //  ----------------------------------------
        //  MARK: THIS IS JUST A MOCK NOW TO TEST PUBLISHER
        //  ----------------------------------------
        return History(saveTo: "", type: .confirmed, deviationThreshold: 100)
    }
    
    
    static func parseCSVToHistorical(csv: String, type: HistoryType) throws -> Historical {
        
        guard csv.isNotEmpty else {
            print("parseCSVToHistory got empty string to parse, throws error")
            throw ParserError.general
        }
        print("parsing nonempty csv for \(type.rawValue)")
        
        
        /// date as String in format m/d/yy
        func dateFromStr(_ str: String) -> Date {
            let strComponents = str.components(separatedBy: "/")
            let hour = 23
            let minutes = 59
            let month = Int(strComponents[0])
            let day = Int(strComponents[1])
            let year = 2000 + (Int(strComponents[2]) ?? 0)
            let timeZone = TimeZone(abbreviation: "UTC")
            return Calendar.current.date(from: DateComponents(timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minutes)) ?? .distantPast
        }
        
        /// parse to table (array of rows)
        let table: [[String]] = CSVParser.parseCVStoTable(from: csv)
        
        var xLabels = [String]()
        var countryRows: [CountryRow] = []
        
        /// parse each row
        for i in 0 ..< table.count {
            let row = table[i]
            
            let provinceState = row[0]
            let countryRegion = row[1]
            /// skip latitude and longitude ([2] & [3]
            
            var points: [Date: Int] = [:]
            var series = [Int] ()
            for j in 4 ..< row.count {
                let date = dateFromStr(table[0][j])
                xLabels.append(date.toString())
                points[date] = Int(row[j])
                series.append(Int(row[j]) ?? 0)
            }
            
            countryRows.append(CountryRow(provinceState: provinceState, countryRegion: countryRegion, points: points, series: series))
        }
        
        let historical = Historical(type: type, xLabels: xLabels, countryRows: countryRows)
        
        return historical
    }
    
    
    static func parseCVStoTable(from csvStr: String) -> [[String]] {
        
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
        
        /// https://stackoverflow.com/questions/43295163/swift-3-1-how-to-get-array-or-dictionary-from-csv
        func cleanCsv(_ csv: String) -> String {
            var cleanFile = csv
            
            /// remove any special characters in a string
            cleanFile = csv
                .components(separatedBy: CharacterSet.symbols)
                .joined(separator: "")
            
            /// unify end of line symbols
            cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
            cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
            //  cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
            //  cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
            
            return cleanFile
        }
        
        var rows = cleanCsv(csvStr).components(separatedBy: "\n")
        
        /// drop last row if empty (реальная ситуация 24.03.2020)
        if rows.count > 1 && rows.last!.isEmpty {
            //            print("!! dropped last empty row")
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
    
}
