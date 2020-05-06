//
//  ObjectSavable.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 20.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

//  https://medium.com/flawless-app-stories/save-custom-objects-into-userdefaults-using-codable-in-swift-5-1-protocol-oriented-approach-ae36175180d8
//

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, Error {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var localizedDescription: String {
        rawValue
    }
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
    
    
    
    
    func setObj<Object>(_ object: Object, forKey: String) where Object: Encodable {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(object) {
            set(data, forKey: forKey)
        } else {
            print(ObjectSavableError.unableToEncode)
        }
    }
    
    /// аналог getObject
    /// - Parameters:
    ///   - forKey: <#forKey description#>
    ///   - empty: значение по умолчанию, если не удается прочитать сохраненное значение
    /// - Returns: сохраненное или дефолтное значение
    func getObj<Object>(forKey: String, /*castTo type: Object.Type,*/ empty: Object) -> Object where Object: Decodable {
        
        guard let data = data(forKey: forKey) else {
//            print(ObjectSavableError.noValue)
            return empty
        }
        
        let decoder = JSONDecoder()
        if let object = try? decoder.decode(Object.self, from: data) {
            return object
        } else {
            print(ObjectSavableError.unableToDecode)
            return empty
        }
    }
}
