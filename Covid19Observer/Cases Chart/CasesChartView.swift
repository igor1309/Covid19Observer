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
    
    @State private var selection = CaseDataType.confirmed
    @State private var showTable = false
    
    var body: some View {
        VStack {
            if sizeClass == .compact {
                VStack {
                    CasesHeaderButton()
                    
                    CaseDataTypePicker(selection: $selection)
                }
            } else {
                HStack {
                    CasesHeaderButton()
                    
                    Spacer()
                    Spacer()
                    Spacer()

                    CaseDataTypePicker(selection: $selection)
                }
            }
            
            
            if coronaStore.cases.isNotEmpty {
                CasesHBarChart(selectedType: $selection)
            } else {
                //  MARK: FINISH THIS
                //
                Text("No data to display\n\nPlease go to Settings and tap Update")
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
        .environment(\.colorScheme, .dark)
    }
}
