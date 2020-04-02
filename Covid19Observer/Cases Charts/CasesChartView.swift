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
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                CasesHeader()
            }
            //CasesHeaderButton()
            
            CaseDataTypePicker(selection: $selectedType)
            
            if coronaStore.cases.isNotEmpty {
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        CaseChart(
                            selectedType: self.selectedType,
                            isBarsTappable: true,
                            width: geo.size.width
                        )
                    }
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
            self.coronaStore.updateIfStoreIsOldOrEmpty()
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
