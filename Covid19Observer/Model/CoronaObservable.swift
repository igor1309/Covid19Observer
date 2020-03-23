//
//  CoronaObservable.swift
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

class CoronaObservable: ObservableObject {
    /// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/Coronavirus_2019_nCoV_Cases/FeatureServer
    /// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/ncov_cases/FeatureServer/1
    /// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/ncov_cases/FeatureServer/2
    
    //    @Published
    var isFiltered = UserDefaults.standard.bool(forKey: "isFiltered") {
        didSet {
            UserDefaults.standard.set(isFiltered, forKey: "isFiltered")
            casesByProvince()
        }
    }
        
    var maxBars = UserDefaults.standard.integer(forKey: "maxBars") {
        didSet {
            UserDefaults.standard.set(maxBars, forKey: "maxBars")
            casesByProvince()
        }
    }
    
    @Published var caseAnnotations = [CaseAnnotations]()
    @Published var coronaOutbreak = (totalCases: "...", totalRecovered: "...", totalDeaths: "...")
    
    @Published var cases = [CaseData]()
    
    @Published var caseType = CaseType.byCountry {
        didSet {
            casesByProvince()
        }
    }
    
    let urlBaseByRegion  = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query"
    let urlBaseByCountry = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/2/query"
    
    var storage = [AnyCancellable]()
    
    private var responseCache: CoronaResponse {
        switch caseType {
        case .byRegion:
            return responseCacheByRegion
        case .byCountry:
            return responseCacheByCountry
        }
    }
    
    private var responseCacheByRegion = CoronaResponse(features: [])
    private var responseCacheByCountry = CoronaResponse(features: [])
    
    init() {
        if maxBars == 0 { maxBars = 15 }
        fetchCoronaCases(caseType: .byRegion)
        fetchCoronaCases(caseType: .byCountry)
    }
    
    func fetchCoronaCases(caseType: CaseType) {
        var base: String {
            switch caseType {
            case .byRegion:
                return urlBaseByRegion
            case .byCountry:
                return urlBaseByCountry
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
                
                print("data downloaded")
                
                switch caseType {
                case .byRegion:
                    self.responseCacheByRegion = response
                case .byCountry:
                    self.responseCacheByCountry = response
                }
                
                self.casesByProvince()
                //                self.casesByProvince(response: response)
        }
        .store(in: &storage)
    }
    
    func casesByProvince() {
        var caseAnnotations: [CaseAnnotations] = []
        var caseData: [CaseData] = []
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in responseCache.features {
            
            let confirmed = cases.attributes.confirmed ?? 0
            let title = cases.attributes.provinceState ?? cases.attributes.countryRegion ?? ""
            
            caseAnnotations.append(
                CaseAnnotations(
                    title: title,
                    subtitle: "\(confirmed.formattedGrouped)",
                    coordinate: .init(latitude: cases.attributes.lat ?? 0.0,
                                      longitude: cases.attributes.longField ?? 0.0)))
            
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
        
        self.coronaOutbreak.totalCases = "\(totalCases.formattedGrouped)"
        self.coronaOutbreak.totalDeaths = "\(totalDeaths.formattedGrouped)"
        self.coronaOutbreak.totalRecovered = "\(totalRecovered.formattedGrouped)"
        
        if isFiltered && caseAnnotations.count > maxBars {
            caseAnnotations = Array(caseAnnotations.prefix(upTo: maxBars))
            caseData = Array(caseData.prefix(upTo: maxBars))
        }
        
        self.caseAnnotations = caseAnnotations
        self.cases = caseData
    }
}

