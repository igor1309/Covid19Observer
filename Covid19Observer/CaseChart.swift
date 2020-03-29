//
//  CaseChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseChart: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    let selectedType: CaseDataType
    let width: CGFloat
    
    var body: some View {
        let maximum: CGFloat
        switch selectedType {
        case .confirmed:
            maximum = CGFloat(coronaStore.cases.map { $0.confirmed }.max() ?? 1)
        case .deaths:
            maximum = CGFloat(coronaStore.cases.map { $0.deaths }.max() ?? 1)
        case .cfr:
            //            maximum = 0.15
            maximum = CGFloat(coronaStore.cases
                //  MARK: - FINISH THIS
                //  move to model
                //
                /// countries with small number of cases can have a huge CFR (Case Fatality Rate) and distort scale
                //                .filter { $0.confirmed > 50 }
                .map { $0.cfr }.max() ?? 0.15)//0.15
        }
        
        
        return VStack {
//            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    if self.selectedType == .cfr {
                        Color.systemTeal
                            .frame(width: 0.5)
                            .offset(x: width / maximum * CGFloat(self.coronaStore.worldCaseFatalityRate))
                            .opacity(0.6)
                    }
                    
                    //                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(0..<self.coronaStore.cases.count, id: \.self) { index in
                            
                            CaseBar(selectedType: self.selectedType, index: index, maximum: maximum, width: self.width)
                            //                            .onTapGesture {
                            //                                self.selectedCountry = self.coronaStore.cases[index].name
                            //                                self.prepareHistoryData()
                            //                            }
                            //                            .sheet(isPresented: self.$showLineChart) {
                            //                                CasesLineChartView()
                            //                                    .environmentObject(self.coronaStore)
                            //                            }
                        }
                    }
                    //                }
                }
//            }
        }
    }
}

//struct CaseChart_Previews: PreviewProvider {
//    static var previews: some View {
//        CaseChart(selectedType: CaseDataType.confirmed)
//    }
//}
