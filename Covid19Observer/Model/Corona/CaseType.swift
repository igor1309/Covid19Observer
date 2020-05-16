//
//  CaseType.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum CaseType: String, CaseIterable, Codable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
    var filename: String { rawValue.lowercased() + ".json" }
    
    var urlBase: String {
        switch self {
        case .byRegion:
            return "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query"
        case .byCountry:
            return "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/2/query"
        }
    }
}
/// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/Coronavirus_2019_nCoV_Cases/FeatureServer
/// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/ncov_cases/FeatureServer/1
/// https://services1.arcgis.com/0MSEUqKaxRlEPj5g/ArcGIS/rest/services/ncov_cases/FeatureServer/2
