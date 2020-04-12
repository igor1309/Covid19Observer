//
//  Population.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let population = try? newJSONDecoder().decode(Population.self, from: jsonData)

import Foundation

typealias Population = [PopulationElement]

struct PopulationElement: Codable, Hashable, Identifiable {
    
    var id: String { combinedKey }
    
    let uid: Int
    let iso2, iso3: String
    let code3, fips: Int?
    let admin2, provinceState, countryRegion: String
    let lat, long: Double?
    let combinedKey: String
    let population: Int?

    enum CodingKeys: String, CodingKey {
        case uid = "UID"
        case iso2, iso3, code3
        case fips = "FIPS"
        case admin2 = "Admin2"
        case provinceState = "Province_State"
        case countryRegion = "Country_Region"
        case lat = "Lat"
        case long = "Long_"
        case combinedKey = "Combined_Key"
        case population = "Population"
    }
}


///  https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data
///  https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv

///    UID Lookup Table Logic
///
///    All countries without dependencies (entries with only Admin0).
///    None cruise ship Admin0: UID = code3. (e.g., Afghanistan, UID = code3 = 4)
///    Cruise ships in Admin0: Diamond Princess UID = 9999, MS Zaandam UID = 8888.
///    All countries with only state-level dependencies (entries with Admin0 and Admin1).
///    Demark, France, Netherlands: mother countries and their dependencies have different code3, therefore UID = code 3. (e.g., Faroe Islands, Denmark, UID = code3 = 234; Denmark UID = 208)
///    United Kingdom: the mother country and dependencies have different code3s, therefore UID = code 3. One exception: Channel Islands is using the same code3 as the mother country (826), and its artificial UID = 8261.
///    Australia: alphabetically ordered all states, and their UIDs are from 3601 to 3608. Australia itself is 36.
///    Canada: alphabetically ordered all provinces (including cruise ships and recovered entry), and their UIDs are from 12401 to 12415. Canada itself is 124.
///    China: alphabetically ordered all provinces, and their UIDs are from 15601 to 15631. China itself is 156. Hong Kong and Macau have their own code3.
///    The US (most entries with Admin0, Admin1 and Admin2).
///    US by itself is 840 (UID = code3).
///    US dependencies, American Samoa, Guam, Northern Mariana Islands, Virgin Islands and Puerto Rico, UID = code3. Their FIPS codes are different from code3.
///    US states: UID = 840 (country code3) + 000XX (state FIPS code). Ranging from 8400001 to 84000056.
///    Out of [State], US: UID = 840 (country code3) + 800XX (state FIPS code). Ranging from 8408001 to 84080056.
///    Unassigned, US: UID = 840 (country code3) + 900XX (state FIPS code). Ranging from 8409001 to 84090056.
///    US counties: UID = 840 (country code3) + XXXXX (5-digit FIPS code).
///    Exception type 1, such as recovered and Kansas City, ranging from 8407001 to 8407999.
///    Exception type 2, only the New York City, which is replacing New York County and its FIPS code.
///    Exception type 3, Diamond Princess, US: 84088888; Grand Princess, US: 84099999.
