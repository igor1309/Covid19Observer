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
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, color: UIColor) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.color = color
    }
}

