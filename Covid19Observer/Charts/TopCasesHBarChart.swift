//  TopCasesHBarChart.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

enum CaseDataType: String, CaseIterable {
    case confirmed = "Confirmed"
    case deaths = "Deaths"
    case deathRate = "Death Rate"
    
    var id: String { rawValue }
}

struct TopCasesHBarChart: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var selection = CaseDataType.confirmed //"Confirmed"
    @State private var showLineChart = false
    @State private var selectedCountry = ""
    
    func textLabel(name: String, width: CGFloat, maxWidth: CGFloat) -> some View {
        Text(name)
            .foregroundColor(width > maxWidth / 2 ? .black : .secondary)
            .font(coronaStore.maxBars > 15 ? .caption : .footnote)
            .frame(width: width > maxWidth / 2 ? width : maxWidth,
                   alignment: width > maxWidth / 2 ? .trailing : .leading)
            .offset(x: width > maxWidth / 2 ? -10 : width + 10)
    }
    
    private func navTitle(_ type: CaseDataType) -> String {
        switch type {
        case .confirmed:
            return "Cases: \(coronaStore.coronaOutbreak.totalCases)"
        case .deaths:
            return "\(type.id): \(coronaStore.coronaOutbreak.totalDeaths)"
        case .deathRate:
            return type.id
        }
    }
    
    private func caseData(_ type: CaseDataType, for index: Int) -> CGFloat {
        switch type {
        case .confirmed:
            return CGFloat(coronaStore.cases[index].confirmed)
        case .deaths:
            return CGFloat(coronaStore.cases[index].deaths)
        case .deathRate:
            return coronaStore.cases[index].confirmed == 0 ? 0 : CGFloat(coronaStore.cases[index].deaths) / CGFloat(coronaStore.cases[index].confirmed)
        }
    }
    
    private func caseDataStr(_ type: CaseDataType, for index: Int) -> String {
        switch type {
        case .confirmed:
            return coronaStore.cases[index].confirmedStr
        case .deaths:
            return coronaStore.cases[index].deathsStr
        case .deathRate:
            let rate = coronaStore.cases[index].confirmed == 0 ? 0 : Double(coronaStore.cases[index].deaths) / Double(coronaStore.cases[index].confirmed)
            return rate.formattedPercentageWithDecimals
        }
    }
    
    fileprivate func colorForType(_ type: CaseDataType) -> Color {
        switch type {
        case .confirmed:
            return Color.systemYellow
        case .deaths:
            return Color.systemRed
        case .deathRate:
            return Color.systemTeal
        }
    }
    
    func prepareJHData() {
        self.coronaStore.selectedCountry = self.selectedCountry
        self.showLineChart = true
    }
    
    var body: some View {
        let maxConfirmed: CGFloat
//            = selection == .deathRate ? 0.1 : CGFloat(coronaStore.cases.map { $0.confirmed }.max() ?? 1)
        switch selection {
        case .confirmed:
            maxConfirmed = CGFloat(coronaStore.cases.map { $0.confirmed }.max() ?? 1)
        case .deaths:
            maxConfirmed = CGFloat(coronaStore.cases.map { $0.deaths }.max() ?? 1)
        case .deathRate:
            maxConfirmed = 0.1
        }
        
        return VStack {
            if coronaStore.cases.isNotEmpty {
                VStack {
                    Picker(selection: $selection, label: Text("Select Confirmed Cases or Deaths")) {
                        ForEach(CaseDataType.allCases, id: \.self) { type in
                            Text(type.id).tag(type)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            ForEach(0..<self.coronaStore.maxBars, id: \.self) { index in
                                ZStack(alignment: .leading) {
                                    
                                    self.colorForType(self.selection)
                                        .frame(width: geo.size.width / maxConfirmed * self.caseData(self.selection, for: index))
                                        .cornerRadius(6)
                                    
                                    self.textLabel(name: "\(self.coronaStore.cases[index].name): \(self.caseDataStr(self.selection, for: index))",
                                        width: geo.size.width / maxConfirmed * self.caseData(self.selection, for: index),
                                        maxWidth: geo.size.width)
                                }
                                .onTapGesture {
                                    self.selectedCountry = self.coronaStore.cases[index].name
                                    self.prepareJHData()
                                }
                                .sheet(isPresented: self.$showLineChart) {
                                    CasesLineChartView()
                                        .environmentObject(self.coronaStore)
                                }
                            }
                        }
                    }
                }
            } else {
                //  MARK: FINISH THIS
                //
                EmptyView()
            }
        }
        .navigationBarTitle(navTitle(selection))
    }
}

struct TopCasesHBarChart_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TopCasesHBarChart()
                .padding()
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
