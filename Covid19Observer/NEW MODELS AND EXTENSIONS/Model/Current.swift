//
//  Current.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import CoreLocation

/// ex Corona
struct Current: Codable {
    let type: CurrentType
    
    //  Data
    
    private(set) var cases = [CaseData]()
    private(set) var caseAnnotations = [CaseAnnotation]()
    
    //  Metadata
    
    private(set) var syncDate: Date// = .distantPast
}

extension Current {
    
    init(type: CurrentType, with response: CoronaResponse) {
        
        guard response.features.isNotEmpty else {
            print("creating empty current \(type.rawValue): response features are empty)")
            self.init(type: type, syncDate: .distantPast)
            return
        }
        
        //  CaseAnnotation
        
        let caseAnnotations: [CaseAnnotation] = response.features
            .map {
                let attributes = $0.attributes
                
                let title = attributes.provinceState ?? attributes.countryRegion ?? ""

                let confirmed = attributes.confirmed ?? 0
                let deaths = attributes.deaths ?? 0

                let cfr = confirmed == 0 ? 0 : Double(deaths) / Double(confirmed)

                let coordinate = CLLocationCoordinate2D(
                    latitude: attributes.latitude ?? 0.0,
                    longitude: attributes.longitude ?? 0.0
                )
                
                return CaseAnnotation(
                    title: title,
                    confirmed: "Confirmed \(confirmed.formattedGrouped)",
                    deaths: "\(deaths.formattedGrouped) deaths",
                    cfr: "CFR \(cfr.formattedPercentageWithDecimals)",
                    value: confirmed,
                    coordinate: coordinate)
        }
        
        //  CaseData
        
        let caseData: [CaseData] = response.features
            .map {
                let attributes = $0.attributes
                                
                let title = attributes.provinceState ?? attributes.countryRegion ?? ""
                
                let confirmed = attributes.confirmed ?? 0
                let deaths = attributes.deaths ?? 0
                let recovered = attributes.recovered ?? 0
                
                return CaseData(
                        name: title,
                        confirmed: confirmed,
                        
                        //  MARK: - new and current cases are stored in Extra, not here
                        //  delete later, after killing Corona & Corona Store
                        //confirmedNew: 0,
                        //confirmedCurrent: 0,
                        
                        recovered: recovered,
                        deaths: deaths//,
                        
                        //  MARK: - new and current cases are stored in Extra, not here
                        //  delete later, after killing Corona & Corona Store
                        //deathsNew: 0,
                        //deathsCurrent: 0
                )
        }
        
        self.init(type: type,
                  cases: caseData,
                  caseAnnotations: caseAnnotations,
                  syncDate: Date()
        )
    }
}
