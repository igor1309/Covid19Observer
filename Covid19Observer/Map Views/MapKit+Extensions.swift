//
//  MapKit+Extensions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 25.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import MapKit

extension MKCoordinateSpan {
    static var regional = MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
    static var area = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
    static var city = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    static var town = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    static var neighborhood = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

extension CLLocationCoordinate2D {
    static var dijon = CLLocationCoordinate2D(latitude: 47.3220, longitude: 5.0415)
    static var moscow = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
}

extension MKPointAnnotation {
    static var london: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2012 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
    static var moscow: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "Moscow"
        annotation.subtitle = "Capital of Russia"
        annotation.coordinate = .moscow
        return annotation
    }
}
