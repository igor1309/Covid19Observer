//
//  CaseAnnotations.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import MapKit

class CaseAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let confirmed: String?
    let deaths: String?
    let cfr: String?
    let value: Int
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
    
    init(title: String?, subtitle: String?, confirmed: String?, deaths: String?, cfr: String?, value: Int, coordinate: CLLocationCoordinate2D, color: UIColor) {
        self.title = title
        self.subtitle = subtitle
        self.confirmed = confirmed
        self.deaths = deaths
        self.cfr = cfr
        self.value = value
        self.coordinate = coordinate
        self.color = color
    }
}

