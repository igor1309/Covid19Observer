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
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var selection = CaseDataType.cfr
    @State private var showTable = false
    
    var body: some View {
        VStack {
            CasesHeaderButton()
            
            CaseDataTypePicker(selection: $selection)
            
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
        CasesChartView()
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
