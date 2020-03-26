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

struct ToolBarButton: View {
    var systemName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .padding(10)
                .roundedBackground(cornerRadius: 8)
        }
    }
}

struct CasesOnMapView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var selectedPlace: CaseAnnotation?
    @State private var showingPlaceDetails = false
    
    @State private var showTable = false
    @State private var showDoublingTime = false
    @State private var showCasesChart = false
    @State private var showLineChart = false
    @State private var showAlert = false
    
    var header: some View {
        VStack(spacing: 10) {
            Text("COVID-19 Data by John Hopkins")
                .font(.subheadline).bold()
            
            Button(action: {
                self.showTable = true
            }) {
                HStack{
                    VStack {
                        Text("\(coronaStore.coronaOutbreak.totalCases)")
                            .font(.subheadline)
                        Text("confirmed")
                    }
                    .foregroundColor(.systemYellow)
                    
                    Spacer()
                    VStack {
                        Text("\(coronaStore.coronaOutbreak.totalRecovered)")
                            .font(.subheadline)
                        Text("recovered")
                    }
                    .foregroundColor(.systemGreen)
                    
                    Spacer()
                    VStack {
                        Text("\(coronaStore.coronaOutbreak.totalDeaths)")
                            .font(.subheadline)
                        Text("deaths")
                    }
                    .foregroundColor(.systemRed)
                    
                    Spacer()
                    VStack {
                        Text("\(coronaStore.worldCaseFatalityRate.formattedPercentageWithDecimals)")
                            .font(.subheadline)
                        Text("CFR")
                    }
                    .foregroundColor(.systemTeal)
                }
                .font(.caption)
                .padding(.horizontal, 8)
            }
            .sheet(isPresented: $showTable, content: {
                CasesTableView()
                    .environmentObject(self.coronaStore)
            })
            
            Divider()
            
            Picker(selection: $coronaStore.caseType, label: Text("Select by Provincee or Country")) {
                ForEach(CaseType.allCases, id: \.self) { type in
                    Text(type.id).tag(type)
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            
        }
        .font(.footnote)
        .padding()
        .roundedBackground()
        .padding(.top, 6)
        .padding(.horizontal)
    }
    
    var shortToolBar: some View {
        HStack {
            ToolBarButton(systemName: "line.horizontal.3.decrease") {
                self.coronaStore.isFiltered.toggle()
            }
            .foregroundColor(coronaStore.isFiltered ? coronaStore.filterColor : .secondary)
            
            Spacer()
            
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
                                    self.coronaStore.updateCasesData()
                                    print("to be done")
                                }]
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    var longToolBar: some View {
        HStack {
            Group {
                ToolBarButton(systemName: "line.horizontal.3.decrease") {
                    self.coronaStore.isFiltered.toggle()
                }
                .foregroundColor(coronaStore.isFiltered ? coronaStore.filterColor : .secondary)
                
                Spacer()
                
                ToolBarButton(systemName: "waveform.path.ecg") {
                    self.showLineChart = true
                }
                .sheet(isPresented: $showLineChart) {
                    CasesLineChartView()
                        .environmentObject(self.coronaStore)
                }
                
                Spacer()
                
                ToolBarButton(systemName: "chart.bar") {
                    self.showCasesChart = true
                }
                .sheet(isPresented: $showCasesChart) {
                    CasesChartView()
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
                        .environmentObject(self.coronaStore)
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
                                        self.coronaStore.updateCasesData()
                                        print("to be done")
                                    }]
                    )
                }
            }
        }
        .padding(6)
        .roundedBackground()
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                
                MapView(
                    caseAnnotations: coronaStore.caseAnnotations,
                    centerCoordinate: $centerCoordinate,
                    selectedPlace: $selectedPlace,
                    selectedCountry: $coronaStore.selectedCountry,
                    showingPlaceDetails: $showingPlaceDetails)
                    .edgesIgnoringSafeArea(.all)
                    .sheet(isPresented: $showingPlaceDetails) {
                         CasesLineChartView()
                            .environmentObject(self.coronaStore)
                }
                    
                
                header
            }

            //  longToolBar
            
            shortToolBar
        }
    }
}
struct CasesOnMapView_Previews: PreviewProvider {
    static var previews: some View {
        CasesOnMapView()
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
