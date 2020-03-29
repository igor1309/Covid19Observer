//  CasesHBarChart.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CasesHBarChart: View {
//    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    
    @Binding var selectedType: CaseDataType
    @State private var showLineChart = false
    @State private var selectedCountry = ""

    let barHeight: CGFloat = 28

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
        
        
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                if self.selectedType == .cfr {
                    Color.systemTeal
                        .frame(width: 0.5)
                        .offset(x: geo.size.width / maximum * CGFloat(self.coronaStore.worldCaseFatalityRate))
                        .opacity(0.6)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(0..<self.coronaStore.cases.count, id: \.self) { index in
                            
                            ZStack(alignment: .leading) {
                                self.colorForType(self.selectedType)
                                    .frame(width: geo.size.width / maximum * self.caseData(self.selectedType, for: index), height: self.barHeight)
                                    .cornerRadius(6)
                                    .saturation(self.coronaStore.cases[index].name == "China" ? 0.3 : 1)
                                
                                self.textLabel(name: "\(self.coronaStore.cases[index].name): \(self.caseDataStr(self.selectedType, for: index))",
                                    width: geo.size.width / maximum * self.caseData(self.selectedType, for: index),
                                    maxWidth: geo.size.width)
                            }
                            .onTapGesture {
                                self.selectedCountry = self.coronaStore.cases[index].name
                                self.prepareHistoryData()
                            }
                            .sheet(isPresented: self.$showLineChart) {
                                CasesLineChartView()
                                    .environmentObject(self.coronaStore)
                            }
                        }
                    }
                }
            }
        }
    }

    func textLabel(name: String, width: CGFloat, maxWidth: CGFloat) -> some View {
        Text(name)
            .foregroundColor(width > maxWidth / 2 ? .black : .secondary)
            .font(.footnote)
            .frame(width: width > maxWidth / 2 ? width : maxWidth,
                   alignment: width > maxWidth / 2 ? .trailing : .leading)
            .offset(x: width > maxWidth / 2 ? -10 : width + 10)
    }
    
    private func caseData(_ type: CaseDataType, for index: Int) -> CGFloat {
        switch type {
        case .confirmed:
            return CGFloat(coronaStore.cases[index].confirmed)
        case .deaths:
            return CGFloat(coronaStore.cases[index].deaths)
        case .cfr:
            return CGFloat(coronaStore.cases[index].cfr)
        }
    }
    
    private func caseDataStr(_ type: CaseDataType, for index: Int) -> String {
        switch type {
        case .confirmed:
            return coronaStore.cases[index].confirmedStr
        case .deaths:
            return coronaStore.cases[index].deathsStr
        case .cfr:
            return coronaStore.cases[index].cfrStr
        }
    }
    
    fileprivate func colorForType(_ type: CaseDataType) -> Color {
        switch type {
        case .confirmed:
            return Color.systemYellow
        case .deaths:
            return Color.systemRed
        case .cfr:
            return Color.systemTeal
        }
    }
    
    func prepareHistoryData() {
        self.coronaStore.selectedCountry = self.selectedCountry
        self.showLineChart = true
    }
}

struct CasesHBarChart_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CasesHBarChart(selectedType: .constant(CaseDataType.cfr))
                .padding(.horizontal)
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
