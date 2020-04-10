//
//  CoronaStore.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//
//  Inspired by
//  https://heartbeat.fritz.ai/coronavirus-visualisation-on-maps-with-swiftui-and-combine-on-ios-c3f6e04c2634
//  https://github.com/anupamchugh/iowncode/tree/master/SwiftUICoronaMapTracker/SwiftUICoronaMapTracker
//

import SwiftUI
import Combine
import SwiftPI

class CoronaStore: ObservableObject {
    
    @Published var selectedCountry: String = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Russia" {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }
    
    @Published var caseType: CaseType { didSet { processCases() }}
    
    @Published private(set) var confirmedHistory: History
    @Published private(set) var deathsHistory: History
    
    @Published private(set) var currentCases = [CaseData]()
    @Published private(set) var caseAnnotations = [CaseAnnotation]()
    @Published private(set) var coronaOutbreak = (
        totalCases: "...",
        totalNewConfirmed: "...",
        totalCurrentConfirmed: "...",
        totalRecovered: "...",
        totalDeaths: "...",
        cfr: "...")
    
    func total(for caseDataType: CaseDataType) -> String {
        switch caseDataType {
        case .confirmed:
            return coronaOutbreak.totalCases
        case .new:
            return coronaOutbreak.totalNewConfirmed
        case .current:
            return coronaOutbreak.totalCurrentConfirmed
        case .deaths:
            return coronaOutbreak.totalDeaths
        case .cfr:
            return coronaOutbreak.cfr
        }
    }
    
    private(set) var worldCaseFatalityRate: Double = 0
    
    @Published private(set) var isCasesUpdateCompleted = true
    
    var isHistoryUpdateCompleted: Bool {
        confirmedHistory.isUpdateCompleted ?? false && deathsHistory.isUpdateCompleted ?? false
    }
    
    var selectedCountryOutbreak: (
        confirmed: String,
        newConfirmed: String,
        currentConfirmed: String,
        deaths: String,
        cfr: String
        ) {
        if let countryCase = currentCases.first(where: { $0.name == selectedCountry }) {
            return (confirmed: countryCase.confirmedStr,
                    newConfirmed: countryCase.newConfirmedStr,
                    currentConfirmed: countryCase.currentConfirmedStr,
                    deaths: countryCase.deathsStr,
                    cfr: countryCase.cfrStr)
        } else {
            return (confirmed: "...", newConfirmed: "...", currentConfirmed: "...", deaths: "...", cfr: "...")
        }
    }
    
    var countryRegions: [String] { currentCases.map { $0.name }.sorted()}
    
    var filterColor: Color { Color(colorCode(for: mapFilterLowerLimit)) }
    
    var isFiltered = UserDefaults.standard.bool(forKey: "isFiltered") {
        didSet {
            UserDefaults.standard.set(isFiltered, forKey: "isFiltered")
            processCases()
        }
    }
    
    var mapFilterLowerLimit = UserDefaults.standard.integer(forKey: "mapFilterLowerLimit") {
        didSet {
            UserDefaults.standard.set(mapFilterLowerLimit, forKey: "mapFilterLowerLimit")
            processCases()
        }
    }
    
    private var storage = [AnyCancellable]()
    
    private var responseCacheByRegion: CoronaResponse
    private var responseCacheByCountry: CoronaResponse
    
    private var responseCache: CoronaResponse {
        switch caseType {
        case .byRegion:
            return responseCacheByRegion
        case .byCountry:
            return responseCacheByCountry
        }
    }
    
    var timeSinceCasesUpdateStr: String { casesModificationDate.hoursMunutesTillNow }
    
    private var casesModificationDate: Date = (UserDefaults.standard.object(forKey: "casesModificationDate") as? Date ?? Date.distantPast) {
        didSet {
            UserDefaults.standard.set(casesModificationDate, forKey: "casesModificationDate")
        }
    }
    
    /// __ hours means data is old
    var isCasesDataOld: Bool { casesModificationDate.distance(to: Date()) > 1 * 60 * 60 }
    
    ///
    var allCountriesCFR: [Int] {
        let confirmed = confirmedHistory.allCountriesTotals
        let deaths = deathsHistory.allCountriesTotals
        
        var allCFR = [Int]()
        for i in 00..<confirmed.count {
            let cfr = confirmed[i] == 0 ? 0 : 100 * 100 * deaths[i] / confirmed[i]
            allCFR.append(cfr)
        }
        return allCFR
    }
    
    init() {
        /// UserDefaults returns 0 if app is new/reinstalled.cleaned up
        if mapFilterLowerLimit == 0 { mapFilterLowerLimit = 100 }
        
        /// always start with Country, not Region
        caseType = CaseType.byCountry
        
        /// load Cases from disk
        /// Cases by Country
        if let response: CoronaResponse = loadJSONFromDocDir("byRegion.json") {
            responseCacheByRegion = response
            print("corona response by Region loaded from JSON-file on disk")
        } else {
            responseCacheByRegion = CoronaResponse(features: [])
            print("no JSON-file with corona response by Region on disk, set to empty cases")
        }
        
        /// Cases by Region
        if let response: CoronaResponse = loadJSONFromDocDir("byCountry.json") {
            responseCacheByCountry = response
            print("corona response by Country loaded from JSON-file on disk")
        } else {
            responseCacheByCountry = CoronaResponse(features: [])
            print("no JSON-file with corona response by Country on disk, set to empty cases")
        }
        
        
        
        ///  https://github.com/CSSEGISandData/COVID-19
        /// confirmed cases dataset
        let confirmedURL = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")!
        /// deaths dataset
        let deathsURL = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")!
        

        /// initialize history data
        confirmedHistory = History(saveIn: "confirmedHistory.json", url: confirmedURL)
        deathsHistory = History(saveIn: "deathsHistory", url: deathsURL)

        /// load saved history data
        confirmedHistory.load()
        deathsHistory.load()

        /// update if data is empty or old
        updateEmptyOrOldStore()
        
        processCases()
        countNewAndCurrentCases()
    }
    
    func updateEmptyOrOldStore() {
        if currentCases.isEmpty || isCasesDataOld {
            print("Cases Data empty or old, need to fetch")
            isCasesUpdateCompleted = false
            updateCasesData() { _ in
                self.countNewAndCurrentCases()
            }
        }
        
        if confirmedHistory.countryCases.isEmpty || confirmedHistory.isDataOld || deathsHistory.countryCases.isEmpty || deathsHistory.isDataOld {
            print("History Data empty or old, need to fetch")
            updateHistoryData() {
                self.countNewAndCurrentCases()
            }
        }
    }
    
    func updateCasesData(completionHandler: @escaping (_ caseType: CaseType) -> Void) {
        fetchCoronaCases(caseType: .byCountry, completionHandler: completionHandler)
        fetchCoronaCases(caseType: .byRegion, completionHandler: completionHandler)
    }
    
    private func fetchCoronaCases(caseType: CaseType, completionHandler: @escaping (_ caseType: CaseType) -> Void) {
        
        isCasesUpdateCompleted = false
        
        /// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/Coronavirus_2019_nCoV_Cases/FeatureServer
        /// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/ncov_cases/FeatureServer/1
        /// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/ncov_cases/FeatureServer/2
        
        var base: String {
            switch caseType {
            case .byRegion:
                return "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query"
            case .byCountry:
                return "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/2/query"
            }
        }
        
        var urlComponents = URLComponents(string: base)!
        urlComponents.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "Confirmed > 0"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "spatialRef", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "*"),
            URLQueryItem(name: "orderByFields", value: "Confirmed desc"),
            URLQueryItem(name: "resultOffset", value: "0"),
            URLQueryItem(name: "cacheHint", value: "true")
        ]
        
        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .map{ $0.data }
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { response in
                
                print("\(caseType.id) data downloaded")
                
                switch caseType {
                case .byRegion:
                    self.responseCacheByRegion = response
                    saveJSONToDocDir(data: response, filename: "byRegion.json")
                case .byCountry:
                    self.responseCacheByCountry = response
                    saveJSONToDocDir(data: response, filename: "byCountry.json")
                }
                
                self.processCases()
                
                self.casesModificationDate = Date()
                self.isCasesUpdateCompleted = true
                
                completionHandler(caseType)
        }
        .store(in: &storage)
    }
    
    private func countNewAndCurrentCases() {
        var totalNewConfirmed = 0
        var totalCurrentConfirmed = 0
        
        for index in currentCases.indices {
            let last = confirmedHistory.last(for: currentCases[index].name)
            let previous = confirmedHistory.previous(for: currentCases[index].name)
            
            let new = last - previous
            currentCases[index].newConfirmed = new
            currentCases[index].newConfirmedStr = new.formattedGrouped
            
            let currentConfirmed = currentCases[index].confirmed - last
            currentCases[index].currentConfirmed = currentConfirmed
            currentCases[index].currentConfirmedStr = currentConfirmed.formattedGrouped
            
            totalNewConfirmed += new
            totalCurrentConfirmed += currentConfirmed
        }
        
        self.coronaOutbreak.totalNewConfirmed = "\(totalNewConfirmed.formattedGrouped)"
        self.coronaOutbreak.totalCurrentConfirmed = "\(totalCurrentConfirmed.formattedGrouped)"
    }

    private func processCases() {
        var caseAnnotations: [CaseAnnotation] = []
        var caseData: [CaseData] = []
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in responseCache.features {
            
            let confirmed = cases.attributes.confirmed ?? 0
            let deaths = cases.attributes.deaths ?? 0
            let cfr = confirmed == 0 ? 0 : Double(deaths) / Double(confirmed)
            let title = cases.attributes.provinceState ?? cases.attributes.countryRegion ?? ""
            
            caseAnnotations.append(
                CaseAnnotation(
                    title: title,
                    subtitle: "Confirmed \(confirmed.formattedGrouped)\n\(deaths.formattedGrouped) deaths\nCFR \(cfr.formattedPercentageWithDecimals)",
                    value: confirmed,
                    coordinate: .init(latitude: cases.attributes.lat ?? 0.0,
                                      longitude: cases.attributes.longField ?? 0.0),
                    color: colorCode(for: confirmed)))
            
            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
            
            caseData.append(
                CaseData(
                    name: title,
                    confirmed: confirmed,
                    confirmedStr: confirmed.formattedGrouped,
                    //  MARK: count new and current cases is called separately
                    newConfirmed: 0,
                    newConfirmedStr: "n/a",
                    currentConfirmed: 0,
                    currentConfirmedStr: "n/a",
                    deaths: deaths,
                    deathsStr: deaths.formattedGrouped,
                    cfr: cfr,
                    cfrStr: cfr.formattedPercentageWithDecimals
            ))
        }
        
        self.coronaOutbreak.totalCases = "\(totalCases.formattedGrouped)"
        self.coronaOutbreak.totalDeaths = "\(totalDeaths.formattedGrouped)"
        self.coronaOutbreak.totalRecovered = "\(totalRecovered.formattedGrouped)"
        worldCaseFatalityRate = totalCases == 0 ? 0 : Double(totalDeaths) / Double(totalCases)
        self.coronaOutbreak.cfr = worldCaseFatalityRate.formattedPercentageWithDecimals
        
        self.caseAnnotations = caseAnnotations.filter { $0.value > (isFiltered ? mapFilterLowerLimit : 0) }
        
        //        if isFiltered && caseAnnotations.count > maxBars {
        //            caseData = Array(caseData.prefix(upTo: maxBars))
        //        }
        self.currentCases = caseData.filter { $0.confirmed > (isFiltered ? mapFilterLowerLimit : 0) }
        //        self.cases = caseData
    }
    
    
    func updateHistoryData(completionHandler: @escaping () -> Void) {
        
        confirmedHistory.isUpdateCompleted = false
        deathsHistory.isUpdateCompleted = false
        
        let confirmedTask = URLSession.shared
            .downloadTask(with: confirmedHistory.url) { localURL, urlResponse, error in
                if let localURL = localURL {
                    if let history = try? String(contentsOf: localURL) {
                        
                        DispatchQueue.main.async {
                            self.confirmedHistory.update(from: history)
                            completionHandler()
                        }
                    }
                }
        }
        confirmedTask.resume()
        
        let deathsTask = URLSession.shared
            .downloadTask(with: deathsHistory.url) { localURL, urlResponse, error in
                if let localURL = localURL {
                    if let history = try? String(contentsOf: localURL) {
                        
                        DispatchQueue.main.async {
                            self.deathsHistory.update(from: history)
                            completionHandler()
                        }                    }
                }
        }
        deathsTask.resume()
    }
    
    
    func colorCode(for number: Int) -> UIColor {
        
        let color: UIColor
        
        switch number {
        case 0...99:
            color = .systemGray
        case 100...499:
            color = .systemGreen
        case 500...999:
            color = .systemBlue
        case 1_000...4_999:
            color = .systemYellow
        case 5_000...9_999:
            color = .systemOrange
        case 10_000...:
            color = .systemRed
        default:
            color = .systemFill
        }
        
        return color
    }
}
