//
//  MapWithLineChartView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import MapKit

/// iPad Only
struct MapWithLineChartView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var selectedPlace: CaseAnnotation? {
        didSet {
            print("selectedPlace: \(selectedPlace?.title ?? "")")
            if selectedPlace != nil {
                coronaStore.selectedCountry = selectedPlace?.title ?? ""
            }
        }
    }
    
    @State private var showingPlaceDetails = false
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                
                
                //  MARK: - FIX THIS
                //  NEED REFACTOR MapView TO SEPARATE VIEW
                MapView(
                    caseAnnotations: self.coronaStore.coronaByCountry.caseAnnotations,
                    centerCoordinate: self.$centerCoordinate,
                    selectedPlace: self.$selectedPlace,
                    selectedCountry: self.$coronaStore.selectedCountry,
                    showingPlaceDetails: self.$showingPlaceDetails)
                    .edgesIgnoringSafeArea(.all)
                    //                    .sheet(isPresented: $showingPlaceDetails) {
                    //                        CasesLineChartView()
                    //                            .environmentObject(self.coronaStore)
                    //                }
                    .frame(width: geo.size.width * 2 / 3)
                
                CountryLineChartSheet()
            }
        }
    }
}

struct MapWithLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithLineChartView()
            .environmentObject(CoronaStore())
    }
}
