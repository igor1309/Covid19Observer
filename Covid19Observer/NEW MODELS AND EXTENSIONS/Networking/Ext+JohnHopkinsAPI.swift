//
//  Ext+JohnHopkinsAPI.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

protocol CoronaAPI {
    func fetchCurrent(type: CurrentType) -> AnyPublisher<Current, Error>
    func fetchHistorical(type: HistoryType) -> AnyPublisher<Historical, Error>
}

extension JohnHopkinsAPI: CoronaAPI {

    ///  fetch non-empty CoronaResponse or throw an Errror (emptyResponse, DecodingError, etc)
    func fetchCurrent(type: CurrentType) -> AnyPublisher<Current, Error> {
        URLSession.shared.fetch(url: Endpoint.status(type).url, type: CoronaResponse.self)
            .tryMap { response in
                if response.features.isEmpty {
                    throw FetchError.emptyResponse
                } else {
                    return response
                }
        }
        .map { Current(type: type, with: $0) }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
        
    ///  fetch non-empty CoronaResponse or throw an Errror (emptyResponse, DecodingError, etc)
    func fetchCorona(type: CurrentType) -> AnyPublisher<CoronaResponse, Error> {
        URLSession.shared.fetch(url: Endpoint.current(type).url, type: CoronaResponse.self)
            .tryMap { response in
                if response.features.isEmpty {
                    throw FetchError.emptyResponse
                } else {
                    return response
                }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    func fetchHistorical(type: HistoryType) -> AnyPublisher<Historical, Error> {
        URLSession.shared.dataTaskPublisher(for: Endpoint.history(type).url)
            .map { String(data: $0.data, encoding: .utf8)! }
            .tryMap { try CSVParser.parseCSVToHistorical(csv: $0, type: type) }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func fetchHistory(type: HistoryType) -> AnyPublisher<History, Error> {
        URLSession.shared.dataTaskPublisher(for: Endpoint.history(type).url)
            .map { String(data: $0.data, encoding: .utf8)! }
            .tryMap { try CSVParser.parseCSVToHistory(csv: $0) }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    

    //  MARK: - Endpoint
    private enum Endpoint {
        case current(CurrentType)
        case status(CurrentType)
        case history(HistoryType)
        
        /// https://github.com/anupamchugh/iowncode/blob/master/SwiftUICoronaMapTracker/SwiftUICoronaMapTracker/ContentView.swift
        private static let currentBase = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/"
        ///  https://github.com/CSSEGISandData/COVID-19
        private static let historyBase = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"
        
        private var base: String {
            switch self {
                
            case .status(CurrentType.byCountry), .current(CurrentType.byCountry):
                /// by country dataset URL
                return Endpoint.currentBase + "2/query"
            case .status(CurrentType.byRegion), .current(CurrentType.byRegion):
                /// by region dataset URL
                return Endpoint.currentBase + "1/query"
            
            case .history(HistoryType.confirmed):
                /// confirmed cases dataset URL
                return Endpoint.historyBase + "time_series_covid19_confirmed_global.csv"
            case .history(HistoryType.deaths):
                /// deaths dataset URL
                return Endpoint.historyBase + "time_series_covid19_deaths_global.csv"
            }
        }
        
        var url: URL {
            switch self {
            case .current(_), .status(_):
                var components = URLComponents(string: self.base)!
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
                return components.url!
                
            case .history(_):
                return URL(string: self.base)!
            }
        }
    }
}
