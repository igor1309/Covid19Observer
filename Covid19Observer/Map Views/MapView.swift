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
        
        /// Update annotations
//        if caseAnnotations.count != view.annotations.count || caseAnnotations.first?.coordinate.latitude != view.annotations.first?.coordinate.latitude || caseAnnotations.last?.coordinate.latitude != view.annotations.last?.coordinate.latitude {
//            view.removeAnnotations(view.annotations)
//            view.addAnnotations(caseAnnotations)
//        }
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
        
        //        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //            guard let pin = view.annotation as? MKPointAnnotation else {
        //                return
        //            }
        //            showingPlaceDetails = true
        //            selectedPlace = pin
        //        }
        //
        //        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        //            guard (view.annotation as? MKPointAnnotation) != nil else {
        //                return
        //            }
        //            selectedPlace = nil
        //        }
        
        //        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //            //  MARK: FIX THIS
        //            //  проблема: при уходе в background вызывает предупреждение
        //            //  Modifying state during view update, this will cause undefined behavior.
        //            self.mapView.center = mapView.centerCoordinate
        //        }
        
//        /// as in BucketList
//        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//            parent.centerCoordinate = mapView.centerCoordinate
//        }

        
        
        
        
        
        
        
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            //  https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
//            //  https://developer.apple.com/documentation/mapkit/mkannotationview
//            //  https://www.hackingwithswift.com/read/16/3/annotations-and-accessory-views-mkpinannotationview
//            guard let caseAnnotation = annotation as? CaseAnnotation else { return nil }
//            
//            /// unique identifier for view reuse
//            let identifier = "covid19"
//            var annotationView: MKPinAnnotationView
//            
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//                as? MKPinAnnotationView {
//                dequeuedView.annotation = caseAnnotation
//                annotationView = dequeuedView
//            } else {
//                annotationView = MKPinAnnotationView(annotation: caseAnnotation, reuseIdentifier: identifier)
//                /// styling
//                annotationView.pinTintColor = caseAnnotation.color
//                
//                let subtitleLabel = UILabel()
//                subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//                subtitleLabel.text = caseAnnotation.subtitle ?? "NA"
//                subtitleLabel.numberOfLines = 0
//                subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
//                subtitleLabel.textColor = .secondaryLabel //.systemRed
//                annotationView.detailCalloutAccessoryView = subtitleLabel
//                
//                /// allow this to show pop up information
//                annotationView.canShowCallout = true
//                
//                /// attach an information button to the view
//                // annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//                let mapIcon = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
//                mapIcon.setBackgroundImage(UIImage(systemName: "waveform.path.ecg"), for: UIControl.State())
//                annotationView.rightCalloutAccessoryView = mapIcon
//            }
//            
//            /// whether it's a new view or a recycled one, send it back
//            return annotationView
//        }
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
                       value: 255,
                       coordinate: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13),
                       color: .systemIndigo)
    }
    static var moscow: CaseAnnotation {
        CaseAnnotation(title: "Moscow", subtitle: "Capital of Russia", value: 300, coordinate: .moscow, color: .systemGray)
    }
}
