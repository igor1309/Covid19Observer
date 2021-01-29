//
//  CaseChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseChart: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    let selectedType: CaseDataType
    let isBarsTappable: Bool
    let width: CGFloat
    
    @State private var showLineChart = false
    @State private var selectedCountry = ""
    @State private var selectedIndex: Int?
    
    let barHeight: CGFloat = 28
    
    
    var body: some View {
        
        let maximum: CGFloat = { store.maximumForCasesChart(type: selectedType) }()
        
        var cfrGridAndAverage: some View {
            Group {
                ///  vertical grid lines only for CFR
                ForEach([0.1, 0.2, 0.3], id: \.self) { step in
                    LeftVerticalLine()
                        .stroke(Color.systemGray3, style: StrokeStyle(lineWidth: 0.5, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                        .offset(x: self.width / maximum * CGFloat(step))
                }
                
                ///  global average CFR line
                if store.outbreak.cfr > 0 {
                    Color.systemTeal
                        .frame(width: 0.5)
                        .offset(x: width / maximum * CGFloat(store.outbreak.cfr))
                        .opacity(0.6)
                }
            }
        }
        
        return VStack {
            
            ZStack(alignment: .leading) {
                
                ///  chart design for cfr is a bit different
                if self.selectedType == .cfr { cfrGridAndAverage }
                
                VStack(alignment: .leading) {
                    ForEach(0..<self.store.currentByCountry.cases.count, id: \.self) { index in
                        
                        CaseBar(
                            selectedType: self.selectedType,
                            index: index,
                            maximum: maximum,
                            width: self.width,
                            barHeight: self.barHeight
                        )
                            .onTapGesture {
                                self.selectedIndex = index
                                self.processTap()
                        }
                    }
                }
                .sheet(isPresented: self.$showLineChart) {
                    CountryLineChartSheet()
                        .environmentObject(self.store)
                        .environmentObject(self.settings)
                }
            }
        }
    }
    
    func processTap() {
        if isBarsTappable && selectedIndex != nil {
            selectedCountry = store.currentByCountry.cases[selectedIndex!].name
            store.selectedCountry = selectedCountry
            showLineChart = true
        }
    }
}

struct CaseChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(.horizontal) {
                CaseChart(selectedType: CaseDataType.confirmed, isBarsTappable: true, width: 300)
            }
            .border(Color.pink)
            .padding(.horizontal)
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        //        .previewLayout(.sizeThatFits)
    }
}
