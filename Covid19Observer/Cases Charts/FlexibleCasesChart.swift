//
//  FlexibleCasesChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct FlexibleCasesChart: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    let selectedType: CaseDataType
    let isBarsTappable: Bool
    
    var body: some View {
        GeometryReader { geo in
            
            ScrollView(.vertical, showsIndicators: false) {
                
                CaseChart(
                    selectedType: self.selectedType,
                    isBarsTappable: self.isBarsTappable,
                    width: geo.size.width
                )
            }
        }
    }
}

struct FlexibleCasesChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            FlexibleCasesChart(selectedType: CaseDataType.cfr, isBarsTappable: true)
                .padding(.horizontal)
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
