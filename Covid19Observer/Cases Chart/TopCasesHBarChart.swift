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
    case deathRate = "Rate"
    
    var id: String { rawValue }
}

struct TopCasesHBarChart: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var selection = CaseDataType.confirmed //"Confirmed"
    @State private var showTable = false
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
            return "Total: \(coronaStore.coronaOutbreak.totalCases)"
        case .deaths:
            return "Total: \(coronaStore.coronaOutbreak.totalDeaths) deaths"
        case .deathRate:
            return "Case Fatality Rate"
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
    
    func prepareHistoryData() {
        self.coronaStore.selectedCountry = self.selectedCountry
        self.showLineChart = true
    }
    
    var body: some View {
        let maximum: CGFloat
        switch selection {
        case .confirmed:
            maximum = CGFloat(coronaStore.cases.map { $0.confirmed }.max() ?? 1)
        case .deaths:
            maximum = CGFloat(coronaStore.cases.map { $0.deaths }.max() ?? 1)
        case .deathRate:
            maximum = 0.15
        }
        
        
        return VStack {
            if coronaStore.cases.isNotEmpty {
                VStack {
                    Button(action: {
                        self.showTable = true
                    }) {
                        HStack {
                            VStack {
                                Text("\(coronaStore.coronaOutbreak.totalCases)")
                                    .font(.subheadline)
                                Text("confirmed")
                            }
                            .foregroundColor(.systemYellow)
                            
                            Spacer()
                            VStack {
                                Text("\(coronaStore.coronaOutbreak.totalRecovered)")
                                    .font(.subheadline)
                                Text("recovered")
                            }
                            .foregroundColor(.systemGreen)
                            
                            Spacer()
                            VStack {
                                Text("\(coronaStore.coronaOutbreak.totalDeaths)")
                                    .font(.subheadline)
                                Text("deaths")
                            }
                            .foregroundColor(.systemRed)
                            
                            Spacer()
                            VStack {
                                Text("\(coronaStore.worldCaseFatalityRate.formattedPercentageWithDecimals)")
                                    .font(.subheadline)
                                Text("CFR")
                            }
                            .foregroundColor(.systemTeal)
                        }
                        .font(.caption)
                        .padding(.horizontal, 6)
                    }
                    .sheet(isPresented: $showTable, content: {
                        CasesTableView()
                            .environmentObject(self.coronaStore)
                    })
                    
                    
                    Picker(selection: $selection, label: Text("Select Confirmed Cases or Deaths")) {
                        ForEach(CaseDataType.allCases, id: \.self) { type in
                            Text(type.id).tag(type)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    
                    GeometryReader { geo in
                        ZStack {
                            if self.selection == .deathRate {
                                Text("World CFR \(self.coronaStore.worldCaseFatalityRate.formattedPercentageWithDecimals)")
                                    .foregroundColor(.systemTeal)
                                    .font(.caption)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .roundedBackground(cornerRadius: 4)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            }
                            
                            ZStack(alignment: .leading) {
                                if self.selection == .deathRate {
                                    Color.systemTeal
                                        .frame(width: 0.5)
                                        .offset(x: geo.size.width / maximum * CGFloat(self.coronaStore.worldCaseFatalityRate))
                                        .opacity(0.6)
                                }
                                
                                VStack(alignment: .leading) {
                                    ForEach(0..<self.coronaStore.maxBars, id: \.self) { index in
                                        ZStack(alignment: .leading) {
                                            
                                            self.colorForType(self.selection)
                                                .frame(width: geo.size.width / maximum * self.caseData(self.selection, for: index))
                                                .cornerRadius(6)
                                            
                                            self.textLabel(name: "\(self.coronaStore.cases[index].name): \(self.caseDataStr(self.selection, for: index))",
                                                width: geo.size.width / maximum * self.caseData(self.selection, for: index),
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
