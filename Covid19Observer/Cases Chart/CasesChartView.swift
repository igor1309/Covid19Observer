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
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var showTable = false
    
    var body: some View {
        NavigationView {
            TopCasesHBarChart()
                
                .padding(.horizontal)
                //  .navigationBarTitle("Confirmed Cases")
                .navigationBarItems(trailing:
                    // Button("Done") { self.presentation.wrappedValue.dismiss()
                    TrailingButtonSFSymbol("table") {
                        self.showTable = true
                    }
                    .sheet(isPresented: $showTable, content: {
                        CasesTableView()
                            .environmentObject(self.coronaStore)
                    })
            )
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
