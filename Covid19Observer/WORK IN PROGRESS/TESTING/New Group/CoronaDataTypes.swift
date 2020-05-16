//
//  CoronaDataTypes.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 24.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum CurrentType: String, CaseIterable, Codable {
    case byCountry = "Country"
    case byRegion = "Region"
    
    var id: String { rawValue }
    var filename: String { rawValue.lowercased() + ".json" }
}

enum HistoryType: String, CaseIterable, Codable {
    case confirmed, deaths
    
    var id: String { rawValue.capitalized }
    var filename: String { rawValue.lowercased() + ".json" }
    
    //  MARK: - УБРАТЬ ЭТО В Endpoint
    var url: URL {
        ///  https://github.com/CSSEGISandData/COVID-19
        switch self {
        case .confirmed:
            /// confirmed cases dataset URL
            return URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")!
        case .deaths:
            /// deaths dataset URL
            return URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")!
        }
    }
}
