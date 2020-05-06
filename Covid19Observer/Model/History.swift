//
//  Cases.swift
//  Doubling
//
//  Created by Igor Malyarov on 17.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI
import Combine

/// <#Description#>
struct History: Codable {
    
    /// нужно суммировать данные по провинциям в следующих странах
    static let countriesWithRegions = ["Australia", "Canada", "China", "Denmark", "France", "Netherlands", "United Kingdom"]
    
    let filename: String
    let kind: HistoryKind
    
    /// значения на оси X (время как String в формате dd.MM.yyyy)
    private(set) var xTime: [String]
    
    private(set) var countryRows: [CountryRow]
    
    private var lastSyncDate: Date
    var isUpdateCompleted: Bool?
    
    var deviations: [Deviation]
    let deviationThreshold: CGFloat
    
    init(saveTo filename: String, kind: HistoryKind, deviationThreshold: CGFloat) {
        self.xTime = []
        self.countryRows = []
        self.lastSyncDate = .distantPast
        self.isUpdateCompleted = nil
        self.filename = filename
        self.kind = kind
        self.deviations = []
        self.deviationThreshold = deviationThreshold
        
        loadSavedHistory()
    }
}

extension History {
    // MARK: FINISH THIS https://bestkora.com/IosDeveloper/swiftui-dlya-konkursnogo-zadaniya-telegram-10-24-marta-2019-goda/
    /// - Parameter chart:
    /// - Returns: <#description#>
    func chartIndex(chart: CountryRow) -> Int {
        return countryRows.firstIndex(where: { $0.id == chart.id })!
    }
}

extension History {
    func fetch() -> AnyPublisher<String, Never> {
        
        func emptyPublisher(completeImmediately: Bool = true) -> AnyPublisher<String, Never> {
            Empty<String, Never>(completeImmediately: completeImmediately).eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map { String(data: $0.data, encoding: .utf8)! }
            .catch { error -> AnyPublisher<String, Never> in
                print("☣️ error decoding: \(error)")
                return emptyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

extension History {
    
    /// update history data from csv
    /// - Parameter casesCSV: fetched data in csv format
    mutating func update(from casesCSV: String, completion: @escaping () -> Void) {
        
        guard casesCSV.isNotEmpty else { return }
        
//        let rows: [CountryRow] = parseCsvToCountryRows(casesCSV)
        parseCsv(casesCSV)
        
//        self.countryRows = rows
        self.lastSyncDate = Date()
        self.isUpdateCompleted = true
        
        self.countDeviations()
        
        /// save to local file if data is not empty
        if countryRows.isNotEmpty {
            print("saving history data to \(filename)")
            saveJSONToDocDir(data: self, filename: self.filename)
        } else {
            //  MARK: FIX THIS
            //  сделать переменную-буфер ошибок и выводить её в Settings или как-то еще
            print("history data is empty")
        }
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    mutating func countDeviations() {
        
        var devs = [Deviation]()
        var visitedCountries = [String]()
        
        for countryCase in countryRows {
            
            let country = countryCase.countryRegion
            
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
                last8days = Array(countryCase.series.suffix(8))
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
            let isGreaterThanThreshold = last >= deviationThreshold || avg >= deviationThreshold
            
            if isSignificantlyChanged && isGreaterThanThreshold {
                devs.append(Deviation(country: country, avg: Double(avg), last: Double(last)))
            }
        }
        
        self.deviations = devs//.sorted(by: { $0.changePercentage > $1.changePercentage })
    }
}

extension History {
    
    var url: URL { kind.url }
    
    var timeSinceUpdateStr: String { lastSyncDate.hoursMunutesTillNow }
    var isDataOld: Bool { lastSyncDate.distance(to: Date()) > 6 * 60 * 60 }
    
    var allCountriesTotals: [Int] {
        guard countryRows.count > 0 else { return [] }
        
        var totals = Array(repeating: 0, count: countryRows[0].series.count)
        
        for row in countryRows {
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

extension History {
    
    /// Parse csv and put data from it into `xTime` and `countryRows` arrays
    /// - Parameter casesCsv: downloaded csv
    private mutating func parseCsv(_ casesCsv: String) {
        
        /// parse to table (array of rows)
        let table: [[String]] = parseCVStoTable(from: casesCsv)
        
        var xTime = [String]()
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
                xTime.append(date.toString())
                points[date] = Int(row[j])
                series.append(Int(row[j]) ?? 0)
            }
            
            countryRows.append(CountryRow(provinceState: provinceState, countryRegion: countryRegion, points: points, series: series))
        }
        
        self.xTime = xTime
        self.countryRows = countryRows
    }
    
    private func parseCVStoTable(from csvStr: String) -> [[String]] {
        
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
    
    /// date as String in format m/d/yy
    private func dateFromStr(_ str: String) -> Date {
        let strComponents = str.components(separatedBy: "/")
        let hour = 23
        let minutes = 59
        let month = Int(strComponents[0])
        let day = Int(strComponents[1])
        let year = 2000 + (Int(strComponents[2]) ?? 0)
        let timeZone = TimeZone(abbreviation: "UTC")
        return Calendar.current.date(from: DateComponents(timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minutes)) ?? .distantPast
    }
}


extension History {
    
    //  MARK: methods to use for stored properties instead of computed
    
    ///    var allCountriesTotals: [Int]
    private func calcAllCountriesTotals() -> [Int] {
        guard countryRows.count > 0 else { return [] }
        
        var totals = Array(repeating: 0, count: countryRows[0].series.count)
        
        for row in countryRows {
            for i in 0..<row.series.count {
                totals[i] += row.series[i]
            }
        }
        
        return totals
    }
    
    ///    var allCountriesDailyChange: [Int]
    private func calcAllCountriesDailyChange() -> [Int] {
        guard allCountriesTotals.count > 1 else { return [] }
        
        var daily = [Int]()
        
        for i in 1..<allCountriesTotals.count {
            daily.append(allCountriesTotals[i] - allCountriesTotals[i-1])
        }
        
        return daily
        
    }
}

extension History {
    
    /// load  History from disk if there is saved data
    private mutating func loadSavedHistory() {
        if let history: History = loadJSONFromDocDir(self.filename) {
            self = history
            print("historical data loaded from \(self.filename) on disk")
        }
    }    
}
