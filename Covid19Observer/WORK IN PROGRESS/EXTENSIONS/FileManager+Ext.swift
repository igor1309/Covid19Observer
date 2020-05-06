//
//  FileManager+Ext.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 21.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

extension FileManager {
    
    /// Based on https://bestkora.com/IosDeveloper/modern-networking-in-swift-5-with-urlsession-combine-and-codable/
    ///
    func load<T: Decodable>(_ nameJSON: String, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        
        //--------------------------------------------------------
        //  MARK: НУЖНО ПЕРЕПИСАТЬ!!! - Важны ошибки (или нет??)
        //
        
        Just(nameJSON)
            .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let file = dir.appendingPathComponent(nameJSON)
                let data = try! Data(contentsOf: file)
                return Just(data)
                    .eraseToAnyPublisher()
        }
        .decode(type: T.self, decoder: decoder)
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

