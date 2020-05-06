//
//  JohnHopkinsAPI.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 25.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

class JohnHopkinsAPI {
    public static let shared = JohnHopkinsAPI()
    
    /// Publishes CoronaResponse with non empty cases ("features") or FetchError
    func fetchCoronaResponseErr(url: URL) -> AnyPublisher<CoronaResponse, FetchError> {
        
        URLSession.shared.fetchAndDecodeErr(url: url, type: CoronaResponse.self)
            .tryMap {
                if $0.features.isEmpty {
                    print("tryMap: recieved empty data from server, throwing error")
                    throw FetchError.emptyResponse
                } else {
                    print("tryMap: recieved some non-empty data from server")
                    return $0
                }
        }
            /// no need in filter - tryMap catches empty
            //.filter {
            //    print("filter: recieved some data from server: filtering empty")
            //    return $0.features.isNotEmpty
            //}
            .mapError { (error) -> FetchError in
                #warning("ЭТО ВСЕ КЕЙСЫ????")
                switch error {
                case let urlError as URLError:
                    return FetchError.urlError(urlError)
                case let decodingError as DecodingError:
                    return FetchError.decodingError(decodingError)
                default:
                    return FetchError.genericError
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// минус этого метода  в том, что запускается исполнение при создании подписки (в отличие от fetchCoronaResponseErr)
    func fetchCoronaResponseFuture(url: URL) -> AnyPublisher<CoronaResponse, FetchError> {
        
        Future<CoronaResponse, FetchError> { [unowned self] promise in
            
            URLSession.shared.fetchAndDecodeErr(url: url, type: CoronaResponse.self)
                //  .print(">>>>> fetchAndDecodeErr")
                .filter {
                    print("recieved some data from server")
                    return $0.features.isNotEmpty }
                .sink(
                    receiveCompletion: { (completion) in
                        if case let .failure(error) = completion {
                            switch error {
                            case let urlError as URLError:
                                promise(.failure(.urlError(urlError)))
                            case let decodingError as DecodingError:
                                promise(.failure(.decodingError(decodingError)))
                            case let apiError as FetchError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(.genericError))
                            }
                        }
                },
                    receiveValue: { promise(.success($0))
                })
                
                .store(in: &self.subscriptions)
        }
        .eraseToAnyPublisher()
    }
    
    /// Never failing publisher of CoronaResponse for given url
    func fetchCoronaResponse(url: URL) -> AnyPublisher<CoronaResponse, Never> {
        
        URLSession.shared.fetchAndDecodeErr(url: url, type: CoronaResponse.self)
            .filter {
                print("recieved some data from server")
                return $0.features.isNotEmpty }
            .catch { error -> AnyPublisher<CoronaResponse, Never> in
                //  MARK: при любой ошибке закончить
                print("error was catched: completing immediately")
                return Empty(completeImmediately: true)
                    .eraseToAnyPublisher()
        }
            //.catch { error -> AnyPublisher<CoronaResponse, Never> in
            //    if error is URLError {
            //        return Just(CoronaResponse(features: []))
            //            .eraseToAnyPublisher()
            //    } else {
            //        return Empty(completeImmediately: true)
            //            .eraseToAnyPublisher()
            //    }
            //}
            .eraseToAnyPublisher()
    }
    
    private var subscriptions = Set<AnyCancellable>()
    deinit {
        for cancell in subscriptions {
            cancell.cancel()
        }
    }
}
