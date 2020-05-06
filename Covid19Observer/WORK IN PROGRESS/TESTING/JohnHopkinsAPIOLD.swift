//
//  JohnHopkinsAPIOLD.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 21.04.2020.
//  Copyhistory © 2020 Igor Malyarov. All historys reserved.
//

import Foundation
import Combine

extension Corona {
    
    
    
    
    //--------------------------------------------
    
    func fetchCoronaCases() -> AnyPublisher<[CoronaCases], Error> {
        URLSession.shared.fetchData(url: endPoint.url)
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .map { $0.features }
            .eraseToAnyPublisher()
    }
    
    func fetchCorona(/*with completion: () -> Void*/) -> AnyPublisher<Corona, Error> {
        URLSession.shared.fetchData(url: endPoint.url)
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            //            .map { $0.features }
            .map { coronaResponse in
                var corona = Corona(self.caseType, endPoint: self.endPoint)
                corona.update(with: coronaResponse) {
                    //                    completion()
                }
                return corona
        }
        .eraseToAnyPublisher()
    }
}

enum JHEndPoint: String, Codable {
    case currentByRegion
    case currentByCountry
    case historyConfirmed
    case historyDeaths
    
    //  MARK: WHERE IS A RIGHT PLACE FOR THIS?
    //-----------
    
    var filename: String { rawValue + ".json" }
    
    //-----------
    
    //  MARK: WHERE IS A RIGHT PLACE FOR THIS?
    //-----------
    private static let currentShelfLife: TimeInterval = 1 * 60 * 60 // DateComponents(hour: 1)
    private static let historyShelfLife: TimeInterval = 4 * 60 * 60
    
    func isOld(lastSyncDate: Date, shelfLife: TimeInterval) -> Bool {
        let distance = lastSyncDate.distance(to: Date())
        return distance > shelfLife
    }
    
    func isOld(lastSyncDate: Date) -> Bool {
        let distance = lastSyncDate.distance(to: Date())
        switch self {
        case .currentByCountry, .currentByRegion:
            return distance > JHEndPoint.currentShelfLife
        default:
            return distance > JHEndPoint.historyShelfLife
        }
    }
    //-----------
    
    
    /// https://github.com/anupamchugh/iowncode/blob/master/SwiftUICoronaMapTracker/SwiftUICoronaMapTracker/ContentView.swift
    private static let currentBase = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/"
    ///  https://github.com/CSSEGISandData/COVID-19
    private static let historyBase = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"
    
    private var base: String {
        switch self {
        case .currentByCountry:
            return JHEndPoint.currentBase + "2/query"
        case .currentByRegion:
            return JHEndPoint.currentBase + "1/query"
        case .historyConfirmed:
            /// confirmed cases dataset URL
            return JHEndPoint.historyBase + "time_series_covid19_confirmed_global.csv"
        case .historyDeaths:
            /// deaths dataset URL
            return JHEndPoint.historyBase + "time_series_covid19_deaths_global.csv"
        }
    }
    
    var url: URL {
        switch self {
        case .currentByRegion, .currentByCountry:
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


enum JohnHopkinsAPIOld {
    static let agent = Agent()
    
    //  https://bestkora.com/IosDeveloper/modern-networking-in-swift-5-with-urlsession-combine-and-codable/
    // Асинхронная выборка на основе URL с сообщениями от сервера
    func fetch<T: Decodable>(_ url: URL,
                             decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                    200...299 ~= httpResponse.statusCode else {
                        throw FetchError.responseError(
                            ((response as? HTTPURLResponse)?.statusCode ?? 500,
                             String(data: data, encoding: .utf8) ?? ""))
                }
                return data
        }
        .decode(type: T.self, decoder: decoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}


struct Agent {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func fetch<T: Decodable>(_ url: URL, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
