//
//  Bundle+Extension.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

//  MARK: НУЖНО ПЕРЕНЕСТИ В SWIFTPI
//

extension Bundle {
    
    //  https://bestkora.com/IosDeveloper/modern-networking-in-swift-5-with-urlsession-combine-and-codable/
    // Выборка данных Модели <T> из файла в Bundle
    func fetch<T: Decodable>(_ nameJSON: String, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        
        Just (nameJSON)
            .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in
                let path = Bundle.main.path(forResource:nameJSON,
                                            ofType: "json")!
                let data = FileManager.default.contents(atPath: path)!
                return Just(data)
                    .eraseToAnyPublisher()
        }
        .decode(type: T.self, decoder: decoder)
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    
    /// If you want to load some JSON from your app bundle when your app runs, it takes quite a few lines of code: you need to get the URL from your bundle, load it into a Data instance, try decoding it, then catch any errors.
    /// The extension is capable of loading any kind of decodable data – your structs, arrays of your structs, and so on.
    /// https://www.hackingwithswift.com/example-code/system/how-to-decode-json-from-your-app-bundle-the-easy-way
    /// - Parameters:
    ///   - type: what you want to decode
    ///   - file: the name of the JSON file in your bundle
    ///   - dateDecodingStrategy: <#dateDecodingStrategy description#>
    ///   - keyDecodingStrategy: <#keyDecodingStrategy description#>
    /// - Returns: let user = Bundle.main.decode(User.self, from: "data.json")
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
