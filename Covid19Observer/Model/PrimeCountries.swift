//
//  PrimeCountries.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 03.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

enum PrimeCountries: CaseIterable {
    ///https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv
    
    case russia, china, us, italy, germany, france, finland, spain
    
    var iso2: String {
        switch self {
        case .russia:
            return "RU"
        case .china:
            return "CN"
        case .us:
            return "US"
        case .italy:
            return "IT"
        case .germany:
            return "DE"
        case .france:
            return "FR"
        case .finland:
            return "FI"
        case .spain:
            return "ES"
        }
    }
    
    var name: String {
        switch self {
        case .russia:
            return "Russia"
        case .china:
            return "China"
        case .us:
            return "US"
        case .italy:
            return "Italy"
        case .germany:
            return "Germany"
        case .france:
            return "France"
        case .finland:
            return "Finland"
        case .spain:
            return "Spain"
        }
    }
}
