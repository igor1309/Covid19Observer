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
    
    func series(for dataKind: DataKind, appendCurrent: Bool) -> [Int] {
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
            return allCountriesCFR
        }
        
        return series
    }
    
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    
    let countriesWithIso2: [String: String]
    
    @Published var caseType: CaseType { didSet { processCases() }}
    
    @Published private(set) var confirmedHistory: History
    @Published private(set) var deathsHistory: History
    
    @Published private(set) var currentCases = [CaseData]()
    @Published private(set) var caseAnnotations = [CaseAnnotation]()
    
    @Published private(set) var outbreak: Outbreak
    
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
        guard let countryCase = currentCases.first(where: { $0.name == selectedCountry }) else { return Outbreak() }
        
        let population = populationOf(country: selectedCountry)
        
        return Outbreak(population: population,
                        confirmed: countryCase.confirmed,
                        confirmedNew: countryCase.confirmedNew,
                        confirmedCurrent: countryCase.confirmedCurrent,
                        recovered: countryCase.recovered,
                        deaths: countryCase.deaths,
                        deathsNew: countryCase.deathsNew,
                        deathsCurrent: countryCase.deathsCurrent)
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
        countriesWithIso2 = population
            .filter { $0.uid < 1_000 }
            .reduce(into: [String: String]()) {
                $0[$1.combinedKey] = $1.iso2
        }
        
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
        
        /// initialize empty and calc in processCases()
        outbreak = Outbreak()
        
        
        /// load saved history data
        confirmedHistory.load()
        deathsHistory.load()
        
        /// update if data is empty or old
        updateEmptyOrOldStore()
        
        processCases()
    }
    
    func updateEmptyOrOldStore() {
        if currentCases.isEmpty || isCasesDataOld {
            print("Cases Data empty or old, need to fetch")
            isCasesUpdateCompleted = false
            updateCasesData() { _ in
                self.countNewAndCurrent()
            }
        }
        
        if confirmedHistory.countryRows.isEmpty || confirmedHistory.isDataOld || deathsHistory.countryRows.isEmpty || deathsHistory.isDataOld {
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
            
            let comfirmedCurrent = currentCases[index].confirmed - confirmedLast
            currentCases[index].confirmedCurrent = comfirmedCurrent
            
            totalConfirmedNew += confirmedNew
            totalConfirmedCurrent += comfirmedCurrent
            
            
            //  Deaths
            
            let deathsLast = deathsHistory.last(for: name)
            let deathsPrevious = deathsHistory.previous(for: name)
            
            let deathsNew = deathsLast - deathsPrevious
            currentCases[index].deathsNew = deathsNew
            
            let deathsCurrent = currentCases[index].deaths - deathsLast
            currentCases[index].deathsCurrent = deathsCurrent
            
            totalDeathsNew += deathsNew
            totalDeathsCurrent += deathsCurrent
            
        }
        
        
        /// other properties of outbreak set in processCases()
        outbreak.confirmedNew = totalConfirmedNew
        outbreak.confirmedCurrent = totalConfirmedCurrent
        
        outbreak.deathsNew = totalDeathsNew
        outbreak.deathsCurrent = totalDeathsCurrent
        
        
    }
    
    private func processCases() {
        var caseAnnotations: [CaseAnnotation] = []
        var caseData: [CaseData] = []
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in responseCache.features {
            
            let recovered = cases.attributes.recovered ?? 0
            let confirmed = cases.attributes.confirmed ?? 0
            let deaths = cases.attributes.deaths ?? 0
            let cfr = confirmed == 0 ? 0 : Double(deaths) / Double(confirmed)
            let title = cases.attributes.provinceState ?? cases.attributes.countryRegion ?? ""
            
            caseAnnotations.append(
                CaseAnnotation(
                    title: title,
                    subtitle: "Confirmed \(confirmed.formattedGrouped)\n\(deaths.formattedGrouped) deaths\nCFR \(cfr.formattedPercentageWithDecimals)",
                    value: confirmed,
                    coordinate: .init(latitude: cases.attributes.latitude ?? 0.0,
                                      longitude: cases.attributes.longitude ?? 0.0),
                    color: colorCode(for: confirmed)))
            
            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
            
            caseData.append(
                CaseData(
                    name: title,
                    confirmed: confirmed,
                    //  MARK: count new and current cases is called separately in countNewAndCurrent()
                    confirmedNew: 0,
                    confirmedCurrent: 0,
                    recovered: recovered,
                    deaths: deaths,
                    //  MARK: count new and current cases is called separately in countNewAndCurrent()
                    deathsNew: 0,
                    deathsCurrent: 0//,
            ))
        }
        
        
        //  MARK: count new and current cases is called separately in countNewAndCurrent()
        outbreak.population = populationOf(country: nil)
        outbreak.confirmed = totalCases
        outbreak.recovered = totalRecovered
        outbreak.deaths = totalDeaths
        
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        caseAnnotations = caseAnnotations.filter { $0.value > (isFiltered ? mapFilterLowerLimit : 0) }
        
        //        if isFiltered && caseAnnotations.count > maxBars {
        //            caseData = Array(caseData.prefix(upTo: maxBars))
        //        }
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        currentCases = caseData.filter { $0.confirmed > (isFiltered ? mapFilterLowerLimit : 0) }
        //        self.cases = caseData
        
        countNewAndCurrent()
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
    
    func total(for caseDataType: CaseDataType) -> String {
        switch caseDataType {
        case .confirmed:
            return outbreak.confirmedStr
        case .new:
            return outbreak.confirmedNewStr
        case .current:
            return outbreak.confirmedCurrentStr
        case .deaths:
            return outbreak.deathsStr
        case .cfr:
            return outbreak.cfrStr
        }
    }
    
    
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
