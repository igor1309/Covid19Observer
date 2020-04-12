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

    //  MARK: FINISH THIS
    //
    var widget: some View {
        
        func row(title: String, value: String, color: Color) -> some View {
            HStack {
                Text(title)
                    .widthPreference(column: 1)
                    .frame(width: columnWidths[1], alignment: .leading)
                Text(value)
                    .widthPreference(column: 2)
                    .frame(width: columnWidths[2], alignment: .trailing)
            }
            .foregroundColor(color)
        }
        
        var outbreak: Outbreak { coronaStore.outbreak }
        
        return VStack(alignment: .leading, spacing: 3) {
            
            row(title: "Confirmed", value: outbreak.confirmed, color: CaseDataType.confirmed.color)
            
            row(title: "Current", value: outbreak.confirmedCurrent, color: CaseDataType.current.color)
            
            row(title: "New", value: outbreak.confirmedNew, color: CaseDataType.new.color)
            
            row(title: "Deaths", value: outbreak.deaths, color: CaseDataType.deaths.color)
        }
        .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
        .font(.system(.caption, design: .monospaced))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .roundedBackground(cornerRadius: 8, color: .secondarySystemBackground)
        .padding(.bottom)
    }
    
    
    var body: some View {
        VStack {
            
            CaseDataTypePicker(selection: $selectedType)
            
            if coronaStore.currentCases.isNotEmpty {
                
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
                    
                    widget
                }
            } else {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        self.settings.selectedTab = 4
                    }) {
                        Text("No data to display\n\nPlease go to Settings and tap Update")
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            self.coronaStore.updateEmptyOrOldStore()
        }
    }
}

struct CasesChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CasesChartView()
                .padding()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
