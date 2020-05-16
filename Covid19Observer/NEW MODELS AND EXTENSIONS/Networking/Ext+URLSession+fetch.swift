//
//  Ext+URLSession+fetch.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

extension URLSession {
    
    ///  Same as fetchAndDecodeErr()
    func fetch<T: Decodable>(url: URL, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        
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
}
