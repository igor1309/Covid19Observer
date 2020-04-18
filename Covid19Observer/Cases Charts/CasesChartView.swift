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
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    var widget: some View {
        
        func row(title: String, value: String, color: Color) -> some View {
            HStack {
                Text(title)
                    .fixedSize()
                    .widthPreference(column: 1)
                    .frame(width: columnWidths[1], alignment: .leading)
                Text(value)
                    .fixedSize()
                    .widthPreference(column: 2)
                    .frame(width: columnWidths[2], alignment: .trailing)
            }
            .foregroundColor(color)
        }
        
        var outbreak: Outbreak { coronaStore.outbreak }
        
        return VStack(alignment: .leading, spacing: 3) {
            
            row(title: "Confirmed", value: outbreak.confirmedStr, color: CaseDataType.confirmed.color)
            
            row(title: "New", value: outbreak.confirmedNewStr, color: CaseDataType.new.color)
            
            row(title: "Current", value: outbreak.confirmedCurrentStr, color: CaseDataType.current.color)
            
            row(title: "Deaths", value: outbreak.deathsStr, color: CaseDataType.deaths.color)
            
            row(title: "Deaths New", value: outbreak.deathsNewStr, color: CaseDataType.new.color)
            
            row(title: "CFR", value: outbreak.cfrStr, color: CaseDataType.cfr.color)
        }
        .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
        .font(.system(.caption, design: .monospaced))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .roundedBackground(cornerRadius: 8, color: .secondarySystemBackground)
        .padding(.bottom)
    }
    
    var body: some View {
        ZStack {
            if coronaStore.currentCases.isNotEmpty {
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
                        .overlay(WidgetOverlay { self.widget })
                        
//                        widget
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
