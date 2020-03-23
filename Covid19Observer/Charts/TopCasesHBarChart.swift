//  TopCasesHBarChart.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TopCasesHBarChart: View {
    @EnvironmentObject var coronaCases: CoronaObservable
//    @State private var maxBars: Int = 20
    
    @State private var selection = "Confirmed"
    
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
            ? self.coronaCases.cases[index].deaths
            : self.coronaCases.cases[index].confirmed)
    }
    
    fileprivate func caseDataStr(for index: Int) -> String {
        return self.selection == "Deaths"
            ? self.coronaCases.cases[index].deathsStr
            : self.coronaCases.cases[index].confirmedStr
    }
    
    var body: some View {
        let maxConfirmed = CGFloat(coronaCases.cases.map { $0.confirmed }.max() ?? 1)
        
        return VStack {
            if coronaCases.cases.isNotEmpty {
                VStack {
                    VStack {
                        HStack {
//                            Text("Top")
                            Text("Top \(self.coronaCases.maxBars)")
                                .font(.headline)
                                .padding()
                            
                            Picker(selection: $coronaCases.maxBars, label: Text("Select Top Qty")) {
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
                            ForEach(0..<self.coronaCases.maxBars, id: \.self) { index in
                                ZStack(alignment: .leading) {
                                    
                                    Color(self.selection == "Deaths" ? .red : .systemYellow)
                                        .frame(width: geo.size.width / maxConfirmed * self.caseData(for: index))
                                        .cornerRadius(6)
                                    
                                    self.textLabel(name: "\(self.coronaCases.cases[index].name): \(self.caseDataStr(for: index))",
                                        width: geo.size.width / maxConfirmed * self.caseData(for: index),
                                        maxWidth: geo.size.width)
                                }
                            }
                        }
                    }
                }
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
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
        .environmentObject(CoronaObservable())
        .environment(\.colorScheme, .dark)
    }
}
