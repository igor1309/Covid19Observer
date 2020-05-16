//
//  URLSession+Ext.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 25.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

extension URLSession {
    
    #warning("How to throw FetchError if $0.features.isEmpty?")
    
    /// Returns a publisher that transforms a dataTaskPublisher for a given URL with error (FetchError)
    func fetchAndDecodeErr<T: Decodable>(url: URL, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, /*FetchError*/Error> {
        dataTaskPublisher(for: url)
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
        .mapError { (error) -> FetchError in
            print("decoding error")
            return FetchError.decodingError(error as! DecodingError)
        }
        .eraseToAnyPublisher()
    }
    
    /// Returns a publisher that transforms a dataTaskPublisher for a given URL with Error (FetchError)
    func fetchData(url: URL) -> AnyPublisher<Data, Error> {
        dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                    200...299 ~= httpResponse.statusCode else {
                        throw FetchError.responseError(
                            ((response as? HTTPURLResponse)?.statusCode ?? 500,
                             String(data: data, encoding: .utf8) ?? ""))
                }
                
                return data
        }
        .eraseToAnyPublisher()
    }
}
