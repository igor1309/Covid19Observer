//
//  PrimeCountries.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 03.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//


//  MARK: DELETE IF NOT USED
//
//  MARK: RENAME selectedCountries
enum PrimeCountries: CaseIterable {
    ///https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv
    
    case russia, us, italy, germany, france, finland, spain, china
    
    var iso2: String {
        switch self {
        case .russia:
            return "RU"
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
        case .china:
            return "CN"
        }
    }
    
    var name: String {
        switch self {
        case .russia:
            return "Russia"
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
        case .china:
            return "China"
        }
    }
}
