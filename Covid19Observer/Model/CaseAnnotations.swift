//
//  CaseAnnotations.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import MapKit

class CaseAnnotation: NSObject, MKAnnotation, Codable {
    let title: String?
    let confirmed: String?
    let deaths: String?
    let cfr: String?
    let value: Int
    let coordinate: CLLocationCoordinate2D
    
    var color: UIColor {
        MapOptions.colorCode(for: value)
    }
    
    init(title: String?, confirmed: String?, deaths: String?, cfr: String?, value: Int, coordinate: CLLocationCoordinate2D/*, color: UIColor*/) {
        self.title = title
        self.confirmed = confirmed
        self.deaths = deaths
        self.cfr = cfr
        self.value = value
        self.coordinate = coordinate
//        self.color = color
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
     
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
