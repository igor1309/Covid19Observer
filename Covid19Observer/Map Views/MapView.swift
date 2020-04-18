//
//  MapView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 25.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var caseAnnotations: [CaseAnnotation]
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedPlace: CaseAnnotation?
    @Binding var selectedCountry: String
    @Binding var showingPlaceDetails: Bool
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        
        //        let region = MKCoordinateRegion(center: centerCoordinate, span: .regional)
        //        mapView.setRegion(region, animated: true)
        
        
        mapView.register(CaseAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        view.delegate = context.coordinator
        
        if caseAnnotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(caseAnnotations)
        }
        
        
        //        view.setCenter(centerCoordinate, animated: true)
        
        //        if let first = caseAnnotations.first{
        //            view.selectAnnotation(first, animated: true)
        //        }
        
        //        if let selectedPlace = selectedPlace {
        //            view.selectAnnotation(selectedPlace, animated: false)
        //        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, showingPlaceDetails: $showingPlaceDetails, selectedPlace: $selectedPlace, selectedCountry: $selectedCountry)
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        @Binding var showingPlaceDetails: Bool
        @Binding var selectedPlace: CaseAnnotation?
        @Binding var selectedCountry: String
        
        init(_ mapView: MapView, showingPlaceDetails: Binding<Bool>, selectedPlace: Binding<CaseAnnotation?>, selectedCountry: Binding<String>) {
            self.parent = mapView
            self._showingPlaceDetails = showingPlaceDetails
            self._selectedPlace = selectedPlace
            self._selectedCountry = selectedCountry
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let caseAnnotation = view.annotation as? CaseAnnotation else {
                return
            }
            selectedPlace = caseAnnotation
            selectedCountry = caseAnnotation.title ?? "n/a"
            showingPlaceDetails = true
        }
        
        //  MARK: - FIXI THIS
        //  SHOULD BE UDED BY IPAD ONLY!!!
        //  EXCESSIVE CALCULATIONS FOR IPHONE!!!!
        //
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let caseAnnotation = view.annotation as? CaseAnnotation else {
                return
            }
            selectedPlace = caseAnnotation
            selectedCountry = caseAnnotation.title ?? "n/a"
        }
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(caseAnnotations: [.london, .moscow],
                centerCoordinate: .constant(.dijon),
                selectedPlace: .constant(.moscow),
                selectedCountry: .constant("Russia"),
                showingPlaceDetails: .constant(false))
    }
}

extension CaseAnnotation {
    static var london: CaseAnnotation {
        CaseAnnotation(title: "London",
                       subtitle: "Home to the 2012 Summer Olympics.",
                       confirmed: nil, deaths: nil, cfr: nil,
                       value: 255,
                       coordinate: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13),
                       color: .systemIndigo)
    }
    static var moscow: CaseAnnotation {
        CaseAnnotation(title: "Moscow", subtitle: "Capital of Russia",
                       confirmed: nil, deaths: nil, cfr: nil,
                       value: 300, coordinate: .moscow, color: .systemGray)
    }
}
