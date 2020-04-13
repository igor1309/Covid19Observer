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


typealias Outbreak = (
    confirmed: String,
    confirmedPercent: String,
    confirmedNew: String,
    confirmedCurrent: String,
    recovered: String,
    deaths: String,
    deathsPercent: String,
    deathsNew: String,
    deathsCurrent: String,
    deathsPerMillion: String,
    cfr: String
)


class CoronaStore: ObservableObject {
    
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    
    /// Return population for the country and for the world if country is nil. `Regions and territories are not yet supported`.
    /// - Parameter country: country name
    /// - Returns: population for the country and for the world if country is nil
    func populationOf(country: String?) -> Int {
        guard let country = country else {
            return population
                .filter { $0.uid < 1000 }
                .reduce(0, { $0 + $1.population! })
        }
        
        guard let pop = population
            .first(where: {
                $0.combinedKey == country && $0.uid < 1000
            }) else { return 0 }
        
        return pop.population ?? 0
    }
    
    @Published var caseType: CaseType { didSet { processCases() }}
    
    @Published private(set) var confirmedHistory: History
    @Published private(set) var deathsHistory: History
    
    @Published private(set) var currentCases = [CaseData]()
    @Published private(set) var caseAnnotations = [CaseAnnotation]()
    @Published private(set) var outbreak: Outbreak = (
        confirmed: "...",
        confirmedPercent: "...",
        confirmedNew: "...",
        confirmedCurrent: "...",
        recovered: "...",
        deaths: "...",
        deathsPercent: "...",
        deathsNew: "...",
        deathsCurrent: "...",
        //  MARK: FINISH THIS
        //
        deathsPerMillion: "???",
        cfr: "...")
    
    func total(for caseDataType: CaseDataType) -> String {
        switch caseDataType {
        case .confirmed:
            return outbreak.confirmed
        case .new:
            return outbreak.confirmedNew
        case .current:
            return outbreak.confirmedCurrent
        case .deaths:
            return outbreak.deaths
        case .cfr:
            return outbreak.cfr
        }
    }
    
    private(set) var worldCaseFatalityRate: Double = 0
    
    @Published private(set) var isCasesUpdateCompleted = true
    
    var isHistoryUpdateCompleted: Bool {
        confirmedHistory.isUpdateCompleted ?? false && deathsHistory.isUpdateCompleted ?? false
    }
    
    @Published var selectedCountry: String = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Russia" {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }
    
    var selectedCountryPopulation: Int {
        /// страна если uid < 1000
        if let pop = population
            .first(where: { $0.countryRegion == selectedCountry && $0.uid < 1000 })?
            .population {
            return pop
        } else {
            return 1
        }
    }
    
    var selectedCountryOutbreak: Outbreak {
        if let countryCase = currentCases.first(where: { $0.name == selectedCountry }) {
            
print(countryCase)
            //  MARK: FINISH THIS
            //
            let population = Double(populationOf(country: selectedCountry))
print("population \(population)")
            let deathsPerMillion: Int
            if population == 0 {
                deathsPerMillion = 0
            } else {
print("countryCase.deaths \(countryCase.deaths)")
                deathsPerMillion = countryCase.deaths / Int(population) * 1_000_000
            }
            
            let confirmedPercent = Double(countryCase.confirmed) / population
            let deathsPercent = Double(countryCase.deaths) / population
            
            return (confirmed: countryCase.confirmedStr,
                    confirmedPercent: confirmedPercent.formattedPercentageWithDecimals,
                    confirmedNew: countryCase.confirmedNewStr,
                    confirmedCurrent: countryCase.confirmedCurrentStr,
                    //  MARK: FINISH THIS
                //
                recovered: "0",
                deaths: countryCase.deathsStr,
                deathsPercent: deathsPercent.formattedPercentageWithDecimals,
                deathsNew: countryCase.deathsNewStr,
                deathsCurrent: countryCase.deathsCurrentStr,
                deathsPerMillion: deathsPerMillion.formattedGrouped,
                cfr: countryCase.cfrStr)
            
        } else {
            return (confirmed: "...",
                    confirmedPercent: "...",
                    confirmedNew: "...",
                    confirmedCurrent: "...",
                    //  MARK: FINISH THIS
                //
                recovered: "???",
                deaths: "...",
                deathsPercent: "...",
                deathsNew: "...",
                deathsCurrent: "...",
                deathsPerMillion: "...",
                cfr: "...")
        }
    }
    
    var countryRegions: [String] { currentCases.map { $0.name }.sorted() }
    
    
    //  MARK: MAP Stuff
    
    var isFiltered = UserDefaults.standard.bool(forKey: "isFiltered") {
        didSet {
            UserDefaults.standard.set(isFiltered, forKey: "isFiltered")
            processCases()
        }
    }
    
    var filterColor: Color { Color(colorCode(for: mapFilterLowerLimit)) }
    
    var mapFilterLowerLimit = UserDefaults.standard.integer(forKey: "mapFilterLowerLimit") {
        didSet {
            UserDefaults.standard.set(mapFilterLowerLimit, forKey: "mapFilterLowerLimit")
            processCases()
        }
    }
    
    
    //  MARK: CoronaResponse
    
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
            //  MARK: FINISH THIS
            //  ГРАФИКЕ СТРОЯТСЯ ПО [Int] нужно переходить к CGFloat
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
        confirmedHistory = History(
            saveIn: "confirmedHistory.json",
            url: confirmedURL,
            deviationThreshold: 100)
        deathsHistory = History(
            saveIn: "deathsHistory.json",
            url: deathsURL,
            deviationThreshold: 10)
        
        /// load saved history data
        confirmedHistory.load()
        deathsHistory.load()
        
        /// update if data is empty or old
        updateEmptyOrOldStore()
        
        processCases()
        countNewAndCurrent()
    }
    
    func updateEmptyOrOldStore() {
        if currentCases.isEmpty || isCasesDataOld {
            print("Cases Data empty or old, need to fetch")
            isCasesUpdateCompleted = false
            updateCasesData() { _ in
                self.countNewAndCurrent()
            }
        }
        
        if confirmedHistory.countryCases.isEmpty || confirmedHistory.isDataOld || deathsHistory.countryCases.isEmpty || deathsHistory.isDataOld {
            print("History Data empty or old, need to fetch")
            updateHistoryData() {
                self.countNewAndCurrent()
            }
        }
    }
    
    func updateCasesData(completionHandler: @escaping (_ caseType: CaseType) -> Void) {
        fetchCoronaCases(caseType: .byCountry, completionHandler: completionHandler)
        fetchCoronaCases(caseType: .byRegion, completionHandler: completionHandler)
    }
    
    private var storage = [AnyCancellable]()
    
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
    
    private func countNewAndCurrent() {
        var totalConfirmedNew = 0
        var totalConfirmedCurrent = 0
        
        var totalDeathsNew = 0
        var totalDeathsCurrent = 0
        
        for index in currentCases.indices {
            
            let name = currentCases[index].name
            
            //  Confirmed Cases
            
            let confirmedLast = confirmedHistory.last(for: name)
            let confirmedPrevious = confirmedHistory.previous(for: name)
            
            let confirmedNew = confirmedLast - confirmedPrevious
            currentCases[index].confirmedNew = confirmedNew
            currentCases[index].confirmedNewStr = confirmedNew.formattedGrouped
            
            let comfirmedCurrent = currentCases[index].confirmed - confirmedLast
            currentCases[index].confirmedCurrent = comfirmedCurrent
            currentCases[index].confirmedCurrentStr = comfirmedCurrent.formattedGrouped
            
            totalConfirmedNew += confirmedNew
            totalConfirmedCurrent += comfirmedCurrent
            
            
            //  Deaths
            
            let deathsLast = deathsHistory.last(for: name)
            let deathsPrevious = deathsHistory.previous(for: name)
            
            let deathsNew = deathsLast - deathsPrevious
            currentCases[index].deathsNew = deathsNew
            currentCases[index].deathsNewStr = deathsNew.formattedGrouped
            
            let deathsCurrent = currentCases[index].deaths - deathsLast
            currentCases[index].deathsCurrent = deathsCurrent
            currentCases[index].deathsCurrentStr = deathsCurrent.formattedGrouped
            
            totalDeathsNew += deathsNew
            totalDeathsCurrent += deathsCurrent
            
        }
        
        self.outbreak.confirmedNew = totalConfirmedNew.formattedGrouped
        self.outbreak.confirmedCurrent = totalConfirmedCurrent.formattedGrouped
        
        self.outbreak.deathsNew = totalDeathsNew.formattedGrouped
        self.outbreak.deathsCurrent = totalDeathsCurrent.formattedGrouped
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
                    confirmedNew: 0,
                    confirmedNewStr: "n/a",
                    confirmedCurrent: 0,
                    confirmedCurrentStr: "n/a",
                    deaths: deaths,
                    deathsStr: deaths.formattedGrouped,
                    //  MARK: count new and current cases is called separately
                    deathsNew: 0,
                    deathsNewStr: "n/a",
                    deathsCurrent: 0,
                    deathsCurrentStr: "n/a",
                    cfr: cfr,
                    cfrStr: cfr.formattedPercentageWithDecimals
            ))
        }
        
        let worldPopulation = Double(populationOf(country: nil))
        let confirmedPercent = Double(totalCases) / worldPopulation
        let totalDeathsPercent = Double(totalDeaths) / worldPopulation
        
        self.outbreak.confirmed = totalCases.formattedGrouped
        self.outbreak.confirmedPercent = confirmedPercent.formattedPercentageWithDecimals
        self.outbreak.deaths = totalDeaths.formattedGrouped
        self.outbreak.deathsPercent = totalDeathsPercent.formattedPercentageWithDecimals
        self.outbreak.recovered = totalRecovered.formattedGrouped
        self.worldCaseFatalityRate = totalCases == 0 ? 0 : Double(totalDeaths) / Double(totalCases)
        self.outbreak.cfr = worldCaseFatalityRate.formattedPercentageWithDecimals
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        self.caseAnnotations = caseAnnotations.filter { $0.value > (isFiltered ? mapFilterLowerLimit : 0) }
        
        //        if isFiltered && caseAnnotations.count > maxBars {
        //            caseData = Array(caseData.prefix(upTo: maxBars))
        //        }
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        self.currentCases = caseData.filter { $0.confirmed > (isFiltered ? mapFilterLowerLimit : 0) }
        //        self.cases = caseData
    }
    
    private var confirmedHistoryStorage = [AnyCancellable]()
    private var deathsHistoryStorage = [AnyCancellable]()
}

extension CoronaStore {
    
    func updateHistoryData(completionHandler: @escaping () -> Void) {
        
        confirmedHistory.isUpdateCompleted = false
        deathsHistory.isUpdateCompleted = false
        
        URLSession.shared
            .dataTaskPublisher(for: confirmedHistory.url)
            .map { String(data: $0.data, encoding: .utf8)! }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { history in
                self.confirmedHistory.update(from: history)
                completionHandler()
        }
        .store(in: &confirmedHistoryStorage)
        
        URLSession.shared
            .dataTaskPublisher(for: deathsHistory.url)
            .map { String(data: $0.data, encoding: .utf8)! }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { history in
                self.deathsHistory.update(from: history)
                completionHandler()
        }
        .store(in: &deathsHistoryStorage)
    }
}

extension CoronaStore {
    
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
