//  TopCasesHBarChart.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TopCasesHBarChart: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var selection = "Confirmed"
    @State private var showLineChart = false
    @State private var selectedCountry = ""
    
    func textLabel(name: String, width: CGFloat, maxWidth: CGFloat) -> some View {
        Text(name)
            .foregroundColor(width > maxWidth / 2 ? .black : .secondary)
            .font(.footnote)
            .frame(width: width > maxWidth / 2 ? width : maxWidth,
                   alignment: width > maxWidth / 2 ? .trailing : .leading)
            .offset(x: width > maxWidth / 2 ? -10 : width + 10)
    }
    
    fileprivate func caseData(for index: Int) -> CGFloat {
        return CGFloat(self.selection == "Deaths"
            ? self.coronaStore.cases[index].deaths
            : self.coronaStore.cases[index].confirmed)
    }
    
    fileprivate func caseDataStr(for index: Int) -> String {
        return self.selection == "Deaths"
            ? self.coronaStore.cases[index].deathsStr
            : self.coronaStore.cases[index].confirmedStr
    }
    
    func prepareJHData() {
        self.coronaStore.selectedCountry = self.selectedCountry
        self.showLineChart = true
    }
    
    var body: some View {
        let maxConfirmed = CGFloat(coronaStore.cases.map { $0.confirmed }.max() ?? 1)
        
        return VStack {
            if coronaStore.cases.isNotEmpty {
                VStack {
                    VStack {
                        HStack {
                            Text("Top \(self.coronaStore.maxBars)")
                                .font(.headline)
                                .padding()
                            
                            Picker(selection: $coronaStore.maxBars, label: Text("Select Top Qty")) {
                                ForEach([10, 15, 20], id: \.self) { qty in
                                    Text("\(qty)").tag(qty)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(SegmentedPickerStyle())
                            
                        }
                        Picker(selection: $selection, label: Text("Select Confirmed Cases or Deaths")) {
                            Text("Confirmed").tag("Confirmed")
                            Text("Deaths").tag("Deaths")
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            ForEach(0..<self.coronaStore.maxBars, id: \.self) { index in
                                ZStack(alignment: .leading) {
                                    
                                    Color(self.selection == "Deaths" ? .red : .systemYellow)
                                        .frame(width: geo.size.width / maxConfirmed * self.caseData(for: index))
                                        .cornerRadius(6)
                                    
                                    self.textLabel(name: "\(self.coronaStore.cases[index].name): \(self.caseDataStr(for: index))",
                                        width: geo.size.width / maxConfirmed * self.caseData(for: index),
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
        .navigationBarTitle(selection == "Deaths" ? "Deaths" : "Confirmed Cases")
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
