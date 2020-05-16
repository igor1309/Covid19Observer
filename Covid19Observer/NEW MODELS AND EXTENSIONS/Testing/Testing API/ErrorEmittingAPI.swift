//
//  ErrorEmittingAPI.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

class ErrorEmittingAPI: CoronaAPI {
    public static let shared = ErrorEmittingAPI()
    
    //
    //
    //  MARK: see Fail https://heckj.github.io/swiftui-notes/#reference-fail
    //            Empty https://heckj.github.io/swiftui-notes/#reference-empty
    //
    
    func fetchCurrent(type: CurrentType) -> AnyPublisher<Current, Error> {
        //        Fail<Current, Error>(error: FetchError.emptyResponse)
        Empty<Current, Error>()
            .eraseToAnyPublisher()
    }
    
    func fetchHistorical(type: HistoryType) -> AnyPublisher<Historical, Error> {
        //        Fail<Historical, Error>(error: FetchError.emptyResponse)
        Empty<Historical, Error>()
            .eraseToAnyPublisher()
    }
}
