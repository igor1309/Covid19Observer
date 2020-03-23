//
//  CasesOnMapView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
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
    @EnvironmentObject var coronaCases: CoronaObservable
    
    @State private var showTable = false
    @State private var showDoublingTime = false
    @State private var showCasesChart = false
    @State private var showLineChart = false
    @State private var showAlert = false
    
    var header: some View {
        VStack(spacing: 10) {
            Text("COVID-19 Data by John Hopkins")
                .font(.subheadline).bold()
            
            HStack{
                VStack {
                    Text("Confirmed")
                    Text("\(coronaCases.coronaOutbreak.totalCases)")
                        .font(.subheadline)
                }
                .foregroundColor(.systemYellow)
                
                Spacer()
                VStack {
                    Text("Recovered")
                    Text("\(coronaCases.coronaOutbreak.totalRecovered)")
                        .font(.subheadline)
                }
                .foregroundColor(.systemGreen)
                
                Spacer()
                VStack {
                    Text("Deaths")
                    Text("\(coronaCases.coronaOutbreak.totalDeaths)")
                        .font(.subheadline)
                }
                .foregroundColor(.systemRed)
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            Picker(selection: $coronaCases.caseType, label: Text("Select by Provincee or Country")) {
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
    
    var toolBar: some View {
        HStack {
            Group {
                ToolBarButton(systemName: "line.horizontal.3.decrease") {
                    self.coronaCases.isFiltered.toggle()
                }
                .foregroundColor(coronaCases.isFiltered ? .systemOrange : .secondary)
                
                Spacer()
                
                ToolBarButton(systemName: "waveform.path.ecg") {
                    self.showLineChart = true
                }
                .sheet(isPresented: $showLineChart) {
                    CasesLineChartView()
                        .environmentObject(JohnsHopkinsData())
                }
                
                Spacer()
                
                ToolBarButton(systemName: "chart.bar") {
                    self.showCasesChart = true
                }
                .sheet(isPresented: $showCasesChart) {
                    CasesChartView()
                        .environmentObject(self.coronaCases)
                }
                
                Spacer()
            }
            
            Group {
                ToolBarButton(systemName: "table") {
                    self.showTable = true
                }
                .sheet(isPresented: $showTable) {
                    CasesTableView()
                        .environmentObject(self.coronaCases)
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
                
                ToolBarButton(systemName: "arrow.2.circlepath.circle") {
                    self.showAlert = true
                }
                .actionSheet(isPresented: $showAlert) {
                    ActionSheet(title: Text("Reload".uppercased()),
                                message: Text("Reload data? Internet connection required."),
                                buttons: [
                                    .cancel(),
                                    .destructive(Text("Yes, reload")) {
                                        //  MARK: FINISH THIS
                                        self.coronaCases.casesByProvince()
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
                
                MapView(coronaCases: coronaCases.caseAnnotations, totalCases: Int(coronaCases.coronaOutbreak.totalCases) ?? 0)
                    .edgesIgnoringSafeArea(.all)
                
                header
            }
            
            //  toolBar
            
            HStack {
                ToolBarButton(systemName: "line.horizontal.3.decrease") {
                    self.coronaCases.isFiltered.toggle()
                }
                .foregroundColor(coronaCases.isFiltered ? .systemOrange : .secondary)
                
                Spacer()
                
                ToolBarButton(systemName: "arrow.2.circlepath.circle") {
                    self.showAlert = true
                }
                .actionSheet(isPresented: $showAlert) {
                    ActionSheet(title: Text("Reload".uppercased()),
                                message: Text("Reload data? Internet connection required."),
                                buttons: [
                                    .cancel(),
                                    .destructive(Text("Yes, reload")) {
                                        //  MARK: FINISH THIS
                                        self.coronaCases.casesByProvince()
                                        print("to be done")
                                    }]
                    )
                }
            }
                //            .padding(6)
                //            .roundedBackground()
                .padding(.horizontal)
                .padding(.bottom, 32)
        }
    }
}
struct CasesOnMapView_Previews: PreviewProvider {
    static var previews: some View {
        CasesOnMapView()
            .environmentObject(CoronaObservable())
            .environment(\.colorScheme, .dark)
    }
}
