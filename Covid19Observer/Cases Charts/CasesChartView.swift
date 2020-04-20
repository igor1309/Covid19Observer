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
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var selectedType = CaseDataType.confirmed
    @State private var showTable = false
        
    var body: some View {
        Group {
            if coronaStore.coronaByCountry.cases.isNotEmpty {
                VStack {
                    CaseDataTypePicker(selection: $selectedType)
                    
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
                
            } else {
                Button(action: {
                    self.settings.selectedTab = 4
                }) {
                    Text("No data to display\nPlease go to Update section in Settings")
                        .lineSpacing(12)
                }
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
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
