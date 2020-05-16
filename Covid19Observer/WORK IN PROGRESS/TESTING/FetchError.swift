//
//  FetchError.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

/// https://bestkora.com/IosDeveloper/modern-networking-in-swift-5-with-urlsession-combine-and-codable/
enum FetchError: Error, LocalizedError, Identifiable {
    var id: String { localizedDescription }
    case urlError(URLError)
    case responseError((status: Int, message: String))
    case decodingError(DecodingError)
    case emptyResponse
    case genericError
    case parsingError
    case dataFromFileError(messega: String)
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
            
        case .responseError((let status, let message)):
            let range = (message.range(of: "message\":")?.upperBound
                ?? message.startIndex)..<message.endIndex
            return "Bad response code: \(status) message : \(message[range])"
            
        case .decodingError(let error):
            var errorToReport = error.localizedDescription
            switch error {
            case .dataCorrupted(let context):
                let details = context.underlyingError?.localizedDescription
                    ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) - (\(details))"
            case .keyNotFound(let key, let context):
                let details = context.underlyingError?.localizedDescription
                    ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
            case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                let details = context.underlyingError?.localizedDescription
                    ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
            @unknown default:
                break
            }
            return errorToReport
            
        case .emptyResponse:
            return "Response is empty"
            
        case .parsingError:
            return "Error parsing"
            
        case .genericError:
            return "An unknown error has been occured"
            
        case .dataFromFileError(messega: let message):
            return message
        }
    }
}

