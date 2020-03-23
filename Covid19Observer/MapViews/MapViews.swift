//
//  MapViews.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    var coronaCases: [CaseAnnotations]
    var totalCases: Int
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        //        MKMapView(frame: .zero)
        
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
        view.delegate = context.coordinator
        
        /// Update annotations
        if coronaCases.count != view.annotations.count || coronaCases.first?.coordinate.latitude != view.annotations.first?.coordinate.latitude {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(coronaCases)
        }
        
        
        
        //        view.addAnnotations(coronaCases)
        //        if let first = coronaCases.first {
        //            view.selectAnnotation(first, animated: true)
        //        }
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    
    var mapViewController: MapView
    
    init(_ control: MapView) {
        self.mapViewController = control
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        /// this is our unique identifier for view reuse
        let identifier = "annotation"
        
        /// attempt to find a cell we can recycle
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            /// we didn't find one; make a new one
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            /// allow this to show pop up information
            annotationView?.canShowCallout = true
            
            /// attach an information button to the view
            // annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = annotation.subtitle ?? "NA"
        subtitleLabel.numberOfLines = 0
        annotationView?.detailCalloutAccessoryView = subtitleLabel
        
        return annotationView
    }
}
