//
//  CasesChartView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesChartView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaCases: CoronaObservable
    
    var body: some View {
        NavigationView {
            TopCasesHBarChart()
                
                .padding(.horizontal)
                //  .navigationBarTitle("Confirmed Cases")
//                .navigationBarItems(trailing: Button("Done") {
//                    self.presentation.wrappedValue.dismiss()
//                })
        }
    }
}

struct CasesChartView_Previews: PreviewProvider {
    static var previews: some View {
        CasesChartView()
            .environmentObject(CoronaObservable())
            .environment(\.colorScheme, .dark)
    }
}
