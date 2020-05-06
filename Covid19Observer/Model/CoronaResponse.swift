//
//  CoronaResponse.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CoronaResponse: Codable {
    public var features: [CoronaCases]
    
    private enum CodingKeys: String, CodingKey {
        case features
    }
}


struct CoronaCases: Codable {
    public var attributes: CaseAttributes
    
    private enum CodingKeys: String, CodingKey {
        case attributes
    }
}

struct CaseAttributes: Codable {
    let confirmed: Int?
    let countryRegion: String?
    let deaths: Int?
    let latitude: Double?
    let longitude: Double?
    let provinceState: String?
    let recovered: Int?
//    let testDecoder: Int
    
    enum CodingKeys: String, CodingKey {
        case confirmed = "Confirmed"
        case countryRegion = "Country_Region"
        case deaths = "Deaths"
        case latitude = "Lat"
        case longitude = "Long_"
        case provinceState = "Province_State"
        case recovered = "Recovered"
//        case testDecoder = "test"
    }
}
