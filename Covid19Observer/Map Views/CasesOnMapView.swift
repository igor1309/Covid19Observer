//
//  CasesOnMapView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import MapKit
import SwiftPI

struct CasesOnMapView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var selectedPlace: CaseAnnotation?
    @State private var showPlaceDetails = false
    
    @State private var showTable = false
    @State private var showDoublingTime = false
    @State private var showCasesChart = false
    @State private var showLineChart = false
    @State private var showAlert = false
    
    var header: some View {
        Group {
            if sizeClass == .compact {
                MapHeaderCompact()
                
            } else {
                MapHeaderRegular()
            }
        }
        .padding(.top, 6)
        .padding(.horizontal)
    }
    
    var filterButton: some View {
        ToolBarButton(systemName: "line.horizontal.3.decrease") {
            self.coronaStore.mapOptions.isFiltered.toggle()
        }
        .foregroundColor(coronaStore.mapOptions.isFiltered ? coronaStore.mapOptions.filterColor : .secondary)
    }
    
    var updateButton: some View {
        ToolBarButton(systemName: "arrow.2.circlepath") {
            self.showAlert = true
        }
        .actionSheet(isPresented: $showAlert) {
            ActionSheet(title: Text("Reload".uppercased()),
                        message: Text("Reload data? Internet connection required."),
                        buttons: [
                            .cancel(),
                            .destructive(Text("Yes, reload")) {
                                //  MARK: FINISH THIS
                                //
                                self.coronaStore.updateCorona() { }
                                print("to be done")
                            }]
            )
        }
    }
    
    var shortToolBar: some View {
        HStack {
            filterButton
            
            Spacer()
            
            updateButton
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    var longToolBar: some View {
        HStack {
            Group {
                filterButton
                
                Spacer()
                
                ToolBarButton(systemName: "waveform.path.ecg") {
                    self.showLineChart = true
                }
                .sheet(isPresented: $showLineChart) {
                    CasesLineChartView(forAllCountries: false)
                        .environmentObject(self.coronaStore)
                        .environmentObject(self.settings)
                }
                
                Spacer()
                
                ToolBarButton(systemName: "chart.bar") {
                    self.showCasesChart = true
                }
                .sheet(isPresented: $showCasesChart) {
                    CasesChartView()
                        .padding()
                        .environmentObject(self.coronaStore)
                }
                
                Spacer()
            }
            
            Group {
                ToolBarButton(systemName: "table") {
                    self.showTable = true
                }
                .sheet(isPresented: $showTable) {
                    CasesTableView()
                        .padding()
                        .environmentObject(self.coronaStore)
                        .environmentObject(self.settings)
                }
                
                Spacer()
                
                ToolBarButton(systemName: "rectangle.on.rectangle.angled") {
                    self.showDoublingTime = true
                }
                .sheet(isPresented: $showDoublingTime) {
                    DoublingTimeView()
                        .environmentObject(Settings())
                }
                
                Spacer()
                
                updateButton
            }
        }
        .padding(6)
        .roundedBackground()
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    var mapView: some View {
        MapView(
            caseAnnotations: coronaStore.coronaByCountry.caseAnnotations,
            centerCoordinate: $centerCoordinate,
            selectedPlace: $selectedPlace,
            selectedCountry: $coronaStore.selectedCountry,
            showingPlaceDetails: $showPlaceDetails)
            
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $showPlaceDetails) {
                CasesLineChartView(forAllCountries: false)
                    .environmentObject(self.coronaStore)
                    .environmentObject(self.settings)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                mapView
                header
            }
            if sizeClass == .compact {
                shortToolBar
            } else {
                longToolBar
                    .fixedSize()
            }
        }
    }
}
struct CasesOnMapView_Previews: PreviewProvider {
    static var previews: some View {
        CasesOnMapView()
            .environmentObject(CoronaStore())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
