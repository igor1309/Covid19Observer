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
    
    var caseAnnotations: [CaseAnnotations]
    var totalCases: Int
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = context.coordinator
        
        /// Update annotations
        if caseAnnotations.count != view.annotations.count || caseAnnotations.first?.coordinate.latitude != view.annotations.first?.coordinate.latitude {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(caseAnnotations)
        }
        
        //  MARK: FINISH THIS
        //  it should select placemark just once!!!
        //  not when MapView is revisited
        /// Select second highest cases place
//        if selectedPlace == nil && caseAnnotations.count > 1 {
//            view.selectAnnotation(caseAnnotations[1], animated: true)
//        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ control: MapView) {
            self.parent = control
        }
        
        /// as in BucketList
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            /// this is our unique identifier for view reuse
            let identifier = "Placemark"
            
            /// attempt to find a cell we can recycle
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                /// we didn't find one; make a new one
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                /// allow this to show pop up information
                annotationView?.canShowCallout = true
                
                /// attach an information button to the view
                // annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                let mapIcon = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
                mapIcon.setBackgroundImage(UIImage(systemName: "waveform.path.ecg"), for: UIControl.State())
                annotationView?.rightCalloutAccessoryView = mapIcon
            }  else {
                /// we have a view to reuse, so give it the new annotation
                annotationView?.annotation = annotation
            }
            
            let subtitleLabel = UILabel()
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.text = annotation.subtitle ?? "NA"
            subtitleLabel.numberOfLines = 0
            subtitleLabel.font = .preferredFont(forTextStyle: .headline)
            subtitleLabel.textColor = .yellow
            annotationView?.detailCalloutAccessoryView = subtitleLabel
            
            return annotationView
        }
        
        /// as in BucketList
        //  MARK: FINISH THIS
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            let placemark = view.annotation as? MKPointAnnotation

            print("annotation tapped")
            parent.selectedPlace = placemark
            parent.showingPlaceDetails = true
        }
    }
}
