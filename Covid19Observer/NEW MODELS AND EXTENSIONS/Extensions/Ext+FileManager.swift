//
//  Ext+FileManager.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

extension FileManager {
    
    /// Publisher emitting decoded data from JSON file in Document Directory, or Error
    /// - Parameters:
    ///   - type: Type of data in file
    ///   - filename: JSON filename with extension
    ///   - decoder: JSONDecoder
    /// - Returns: Publisher emitting decoded data from JSON file in Document Directory, or Error
    public func loadJSON<T: Decodable>(type: T.Type,
                                       from filename: String,
                                       decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        
        //--------------------------------------------------------
        //  MARK: НУЖНО ПЕРЕПИСАТЬ!!! - Важны ошибки (или нет??)
        //
        
        Just(filename)
            .setFailureType(to: Error.self)
            .tryMap { (nameJSON) -> JSONDecoder.Input in
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let file = dir.appendingPathComponent(nameJSON)
                let data = try? Data(contentsOf: file)
                if data == nil {
                    throw FetchError.dataFromFileError(messega: "error reading data from file \(nameJSON)")
                } else {
                    return data!
                }
        }
        .decode(type: T.self, decoder: decoder)
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    
    /// a bit different than saveJSONToDocDir in SwiftPI, uses DispatchQueue.global().async
    /// - Parameters:
    ///   - data: date to save
    ///   - filename: filename with extension
    ///   - encoder: JSONEncoder
    public func saveJSON<T: Codable>(data: T, to filename: String, encoder: JSONEncoder = JSONEncoder()) {
        DispatchQueue.global().async {
            encoder.outputFormatting = .prettyPrinted
            
            let jsonData: Data
            do {
                jsonData = try encoder.encode(data)
            }
            catch {
                print("error encoding data")
                return
            }
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("error creating JSON string from data")
                return
            }
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(filename)
                print("saveJSON: fileURL: \(fileURL)")
                
                do {
                    try jsonString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                }
                catch {
                    print("error writing encoded data to file")
                    return
                }
            }
            else { print("error getting Document Directory") }
        }
    }
}
