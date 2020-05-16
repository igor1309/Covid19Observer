//
//  Corona.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine
import SwiftPI

struct Corona: Codable {
    let caseType: CaseType
    let endPoint: JHEndPoint
//    let filename: String
    var filename: String { endPoint.rawValue.lowercased() + ".json" }
    
    var cases = [OldCaseData]()
    private(set) var caseAnnotations = [CaseAnnotation]()
    
    private(set) var lastSyncDate: Date
    var isUpdateCompleted: Bool?
    
    init(_ caseType: CaseType, endPoint: JHEndPoint/*, saveTo filename: String*/) {
        self.caseType = caseType
        self.endPoint = endPoint
        self.lastSyncDate = .distantPast
        self.isUpdateCompleted = nil
//        self.filename = filename
        
        loadSavedCorona()
    }
}

extension Corona {
    init(from response: CoronaResponse, caseType: CaseType, endPoint: JHEndPoint) {
        //  MARK: FINISH THIS
        var corona = Corona(caseType, endPoint: endPoint)
        
        guard response.features.isNotEmpty else {
            self = corona
            return
        }
        
        corona.update(with: response, completion: {})
        
        self = corona
    }
}

extension Corona {
    
    func fetch() -> AnyPublisher<CoronaResponse, Never> {
        
        func emptyPublisher(completeImmediately: Bool = true) -> AnyPublisher<CoronaResponse, Never> {
            Empty<CoronaResponse, Never>(completeImmediately: completeImmediately).eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: urlComponents.url!)
            .map { $0.data }
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<CoronaResponse, Never> in
                print("☣️ error decoding: \(error)")
                return emptyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    mutating func update(with response: CoronaResponse, completion: @escaping () -> Void) {
        
        guard response.features.isNotEmpty else {
            print("response is empty, nothing to process")
            self.isUpdateCompleted = true
            return
        }
        
        /// `process`
        processCases(response: response)
        
        /// …
        
        /// marks
        self.lastSyncDate = Date()
        self.isUpdateCompleted = true
        
        /// save to local file if data is not empty
        if cases.isNotEmpty {
            print("saving current \(caseType.id) data")
            saveJSONToDocDir(data: self, filename: self.filename)
        } else {
            //  MARK: FIX THIS
            //  сделать переменную-буфер ошибок и выводить её в Settings или как-то еще
            print("case data is empty")
        }

        DispatchQueue.main.async {
            completion()
        }
    }
        
    private mutating func processCases(response: CoronaResponse) {
        var caseAnnotations: [CaseAnnotation] = []
        var caseData: [OldCaseData] = []
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in response.features {
            
            let recovered = cases.attributes.recovered ?? 0
            let confirmed = cases.attributes.confirmed ?? 0
            let deaths = cases.attributes.deaths ?? 0
            let cfr = confirmed == 0 ? 0 : Double(deaths) / Double(confirmed)
            let title = cases.attributes.provinceState ?? cases.attributes.countryRegion ?? ""
            
            
            caseAnnotations.append(
                CaseAnnotation(
                    title: title,
                    confirmed: "Confirmed \(confirmed.formattedGrouped)",
                    deaths: "\(deaths.formattedGrouped) deaths",
                    cfr: "CFR \(cfr.formattedPercentageWithDecimals)",
                    value: confirmed,
                    coordinate: .init(latitude: cases.attributes.latitude ?? 0.0,
                                      longitude: cases.attributes.longitude ?? 0.0)))
            
            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
            
            caseData.append(
                OldCaseData(
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
        
        
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        //        self.caseAnnotations = caseAnnotations.filter { $0.value > (mapOptions.isFiltered ? mapOptions.lowerLimit : 0) }
        self.caseAnnotations = caseAnnotations
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        //        self.currentCases = caseData.filter { $0.confirmed > (mapOptions.isFiltered ? mapOptions.lowerLimit : 0) }
        self.cases = caseData
        
        // ЭТО В CORONASTORE!
        // countNewAndCurrent()
    }
    
}

extension Corona {
    var timeSinceCasesUpdateStr: String {
        lastSyncDate.hoursMunutesTillNow
    }
    /// x hours means data is old
    var isDataOld: Bool {
        lastSyncDate.distance(to: Date()) > 1 * 60 * 60
    }
    
    var urlBase: String { caseType.urlBase }
    
    var urlComponents: URLComponents {
        
        var components = URLComponents(string: urlBase)!
        components.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "Confirmed > 0"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "spatialRef", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "*"),
            URLQueryItem(name: "orderByFields", value: "Confirmed desc"),
            URLQueryItem(name: "resultOffset", value: "0"),
            URLQueryItem(name: "cacheHint", value: "true")
        ]
        
        return components
    }
    
    /// load  Corona data from disk if there is saved data
    private mutating func loadSavedCorona() {
        guard let corona: Corona = loadJSONFromDocDir(filename) else {
            //  MARK: FINISH THIS!!!
            // just return???
            print("error loading corona data from \(filename) on disk")
            return
        }
        
        print("loaded corona data from \(filename) on disk")
        self = corona
    }
}

