//
//  CasesChartView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CasesChartView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var selectedType = CaseDataType.confirmed
    @State private var showTable = false
    
    var chartWithWidget: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    
                    CaseChart(
                        selectedType: self.selectedType,
                        isBarsTappable: true,
                        width: geo.size.width
                    )
                }
            }
            .overlay(WidgetOverlay { CasesChartWidget() })
        }
    }
    
    var callToUpdate: some View {
        VStack {
            Text("No data to display")
            
            SpinningWaitCurrentButton()
        }
    }
    
    var body: some View {
        Group {
            if store.currentByCountry.cases.isNotEmpty {
                VStack {
                    CaseDataTypePicker(selection: $selectedType)
                    
                    Text(selectedType.rawValue)
                        .foregroundColor(selectedType.color)
                        .font(.subheadline)
                    
                    chartWithWidget
                }
            } else {
                callToUpdate
            }
        }
    }
}

struct CasesChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CasesChartView()
                .padding(.horizontal)
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
