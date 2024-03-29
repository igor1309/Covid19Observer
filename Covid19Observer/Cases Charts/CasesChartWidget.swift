//
//  CasesChartWidget.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// shows nothing (EmptyView) if `outbreak` is zero
struct CasesChartWidget: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var showTable = false
    
    let spacing: CGFloat = 16
    
    var outbreak: Outbreak { store.outbreak }
    
    var widget: some View {
        VStack(alignment: .leading, spacing: 3) {
            Group {
                row(title: "Confirmed", value: outbreak.confirmedStr, color: CaseDataType.confirmed.color)
                
                row(title: "New", value: outbreak.confirmedNewStr, color: CaseDataType.new.color)
                
                row(title: "Current", value: outbreak.confirmedCurrentStr, color: CaseDataType.current.color)
                
                row(title: "Deaths", value: outbreak.deathsStr, color: CaseDataType.deaths.color)
                
                row(title: "Deaths New", value: outbreak.deathsNewStr, color: CaseDataType.new.color)
                
                row(title: "CFR", value: outbreak.cfrStr, color: CaseDataType.cfr.color)
                
                Divider()
                    .padding(.top, 3)
                    .frame(maxWidth: spacing + (columnWidths[1] ?? 0) + (columnWidths[2] ?? 0))
            }
            .contentShape(Rectangle())
            .onLongPressGesture {
                self.showTable = true
            }
            
            Button(action: {
                self.showTable = true
            }) {
                Text("show table")
                    .font(.caption)
            }
            .sheet(isPresented: $showTable) {
                CasesTableView()
                    .environmentObject(self.store)
                    .environmentObject(self.settings)
            }
        }
        .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
        .font(.system(.caption, design: .monospaced))
        .padding(.top, 8)
        .padding(.bottom, 6)
        .padding(.horizontal, 12)
        .roundedBackground(cornerRadius: 8, color: .secondarySystemBackground)
        .padding(.bottom)
    }
    
    var body: some View {
        Group {
            if outbreak.confirmed > 0 {
                widget
            } else {
                EmptyView()
            }
        }
    }
    
    func row(title: String, value: String, color: Color) -> some View {
        HStack(spacing: spacing) {
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
}

struct CasesChartWidget_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CasesChartWidget()
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
