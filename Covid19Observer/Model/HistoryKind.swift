//
//  HistoryKind.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 20.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum HistoryKind: String, CaseIterable, Codable {
    case confirmed
    case deaths
    
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

