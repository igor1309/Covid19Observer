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
    
    @Published var caseType: CaseType { didSet { processCases() }}
    
    @Published var history: History = History(from: "")
    @Published var cases = [CaseData]()
    @Published var caseAnnotations = [CaseAnnotation]()
    @Published var coronaOutbreak = (totalCases: "...", totalRecovered: "...", totalDeaths: "...")
    
    var worldCaseFatalityRate: Double = 0
    
    @Published var isCasesUpdateCompleted = true
    @Published var isHistoryUpdateCompleted = true
    
    @Published var selectedCountry: String = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Russia" {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }
    
    var countryRegions: [String] { cases.map { $0.name }.sorted()}
    
    var selectedCountryOutbreak: (totalCases: String, totalDeaths: String) {
        if let countryCase = cases.first(where: { $0.name == selectedCountry }) {
            return (totalCases: countryCase.confirmedStr,
                    totalDeaths: countryCase.deathsStr)
        } else {
            return (totalCases: "...", totalDeaths: "...")
        }
    }
    
    var filterColor: Color { Color(colorCode(number: mapFilterLowerLimit)) }
    
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
    
    var maxBars = UserDefaults.standard.integer(forKey: "maxBars") {
        didSet {
            UserDefaults.standard.set(maxBars, forKey: "maxBars")
            processCases()
        }
    }
    
    var hoursMunutesSinceCasesUpdateStr: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: casesModificationDate, to: Date())  ?? "n/a"
    }
    
    var hoursMunutesSinceHistoryUpdateStr: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: historyModificationDate, to: Date())  ?? "n/a"
    }
    
    var storage = [AnyCancellable]()
    
    private var responseCache: CoronaResponse {
        switch caseType {
        case .byRegion:
            return responseCacheByRegion
        case .byCountry:
            return responseCacheByCountry
        }
    }
    
    private var responseCacheByRegion: CoronaResponse
    private var responseCacheByCountry: CoronaResponse
    
    init() {
        if mapFilterLowerLimit == 0 { mapFilterLowerLimit = 100 }
        if maxBars == 0 { maxBars = 15 }
        
        caseType = CaseType.byCountry
        
        if let response: CoronaResponse = loadJSONFromDocDir("byRegion.json") {
            responseCacheByRegion = response
            print("corona response by Region loaded from JSON-file on disk")
        } else {
            responseCacheByRegion = CoronaResponse(features: [])
            print("no JSON-file with corona response by Region on disk, set to empty cases")
        }
        
        if let response: CoronaResponse = loadJSONFromDocDir("byCountry.json") {
            responseCacheByCountry = response
            print("corona response by Country loaded from JSON-file on disk")
        } else {
            responseCacheByCountry = CoronaResponse(features: [])
            print("no JSON-file with corona response by Country on disk, set to empty cases")
        }
        
        processCases()
        
        if let history: History = loadJSONFromDocDir("history.json") {
            self.history = history
            print("historical data loaded from JSON-file on disk")
        } else {
            self.history = History(from: "")
            print("no JSON-file with historical data on disk, set to empty")
        }
    }
    
    private var casesModificationDate: Date = (UserDefaults.standard.object(forKey: "casesModificationDate") as? Date ?? Date.distantPast) {
        didSet {
            UserDefaults.standard.set(casesModificationDate, forKey: "casesModificationDate")
        }
    }
    
    private var historyModificationDate: Date = (UserDefaults.standard.object(forKey: "historyModificationDate") as? Date ?? Date.distantPast) {
        didSet {
            UserDefaults.standard.set(historyModificationDate, forKey: "historyModificationDate")
        }
    }
    
    private var isCasesDataOld: Bool { casesModificationDate.distance(to: Date()) / 60 > 120 }
    private var isHistoryDataOld: Bool { casesModificationDate.distance(to: Date()) / 60 > 120 }
    
    func updateIfStoreIsOldOrEmpty() {
        if cases.isEmpty || isCasesDataOld {
            isCasesUpdateCompleted = false
            updateCasesData()
        }
        
        if history.table.isEmpty || isHistoryDataOld {
            isHistoryUpdateCompleted = false
            updateHistoryData()
        }
    }
    
    func updateHistoryData() {
        fetchHistoryData()
    }
    
    func updateCasesData() {
        fetchCoronaCases(caseType: .byCountry)
        fetchCoronaCases(caseType: .byRegion)
    }
    
    private func fetchCoronaCases(caseType: CaseType) {
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
        }
        .store(in: &storage)
    }
    
    func colorCode(number: Int) -> UIColor {
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
                    color: colorCode(number: confirmed)))
            
            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
            
            caseData.append(
                CaseData(
                    name: title,
                    confirmed: confirmed,
                    confirmedStr: confirmed.formattedGrouped,
                    deaths: (cases.attributes.deaths ?? 0),
                    deathsStr: (cases.attributes.deaths ?? 0).formattedGrouped
            ))
        }
        
        self.worldCaseFatalityRate = totalCases == 0 ? 0 : Double(totalDeaths) / Double(totalCases)
        print("World Case Fatality Rate: \(worldCaseFatalityRate)")
        self.coronaOutbreak.totalCases = "\(totalCases.formattedGrouped)"
        self.coronaOutbreak.totalDeaths = "\(totalDeaths.formattedGrouped)"
        self.coronaOutbreak.totalRecovered = "\(totalRecovered.formattedGrouped)"
        
        self.caseAnnotations = caseAnnotations.filter { $0.value > (isFiltered ? mapFilterLowerLimit : 0) }

//        if isFiltered && caseAnnotations.count > maxBars {
//            caseData = Array(caseData.prefix(upTo: maxBars))
//        }
        self.cases = caseData.filter { $0.confirmed > (isFiltered ? mapFilterLowerLimit : 0) }
//        self.cases = caseData
    }
    
    func fetchHistoryData() {
        isHistoryUpdateCompleted = false
        
        ///  https://github.com/CSSEGISandData/COVID-19
        let url = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")!
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let casesStr = try? String(contentsOf: localURL) {
                    DispatchQueue.main.async {
                        self.history = History(from: casesStr)
                        saveJSONToDocDir(data: self.history, filename: "history.json")
                        
                        self.historyModificationDate = Date()
                        self.isHistoryUpdateCompleted = true
                    }
                }
            }
        }
        
        task.resume()
    }
}

