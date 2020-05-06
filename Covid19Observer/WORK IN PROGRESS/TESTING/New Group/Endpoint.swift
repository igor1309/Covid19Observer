//
//  Endpoint.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 24.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum Endpoint {
    case current(CurrentType)
    case history(HistoryType)
    
    /// https://github.com/anupamchugh/iowncode/blob/master/SwiftUICoronaMapTracker/SwiftUICoronaMapTracker/ContentView.swift
    private static let currentBase = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/"
    ///  https://github.com/CSSEGISandData/COVID-19
    private static let historyBase = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"
    
    private var base: String {
        switch self {
        case .current(CurrentType.byCountry):
            /// by country dataset URL
            return Endpoint.currentBase + "2/query"
        case .current(CurrentType.byRegion):
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
        case .current(_):
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
            
        default:
            return URL(string: self.base)!
        }
    }
}

extension Endpoint: Codable {
    private enum CodingKeys: CodingKey {
        case current
        case history
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .current(let value):
            try container.encode(value, forKey: .current)
        case .history(let value):
            try container.encode(value, forKey: .history)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let currentValue = try container.decode(CurrentType.self, forKey: .current)
            self = .current(currentValue)
        } catch {
            let historyValue = try container.decode(HistoryType.self, forKey: .history)
            self = .history(historyValue)
        }
    }
}
