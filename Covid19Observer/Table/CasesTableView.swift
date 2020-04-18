//
//  CasesTableView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesTableView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var showLineChart = false
    
    var body: some View {
        
        func row(col1: String, col2: String, col3: String, col4: String, isHeader: Bool = false) -> some View {
            return HStack {
                
                Text(col1)
                    .foregroundColor(isHeader ? .secondary : .primary)
                    .font(isHeader ? .caption : .subheadline)
                    .padding(.leading, isHeader ? 12 : 6)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Group {
                    Text(col2)
                        .foregroundColor(isHeader ? .secondary : .systemYellow)
                        .padding(.leading, 12)
                        .padding(.trailing, 6)
                        .fixedSize()
                        .widthPreference(column: 81)
                        .frame(width: self.columnWidths[81], alignment: isHeader ? .leading : .trailing)
                    
                    Text(col3)
                        .foregroundColor(isHeader ? .secondary : .systemRed)
                        .padding(.leading, 12)
                        .padding(.trailing, 6)
                        .fixedSize()
                        .widthPreference(column: 82)
                        .frame(width: self.columnWidths[82], alignment: isHeader ? .leading : .trailing)
                    
                    Text(col4)
                        .foregroundColor(isHeader ? .secondary : .systemTeal)
                        .padding(.leading, 12)
                        .padding(.trailing, 6)
                        .fixedSize()
                        .widthPreference(column: 83)
                        .frame(width: self.columnWidths[83], alignment: isHeader ? .center : .trailing)
                }
                .font(isHeader ? .caption : .system(.footnote, design: .monospaced))
            }
        }
        
        return NavigationView {
            VStack {
                row(col1: "Country", col2: "Confirmed", col3: "Deaths", col4: "CFR", isHeader: true)
                    .padding(.top)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(coronaStore.currentCases.indices, id: \.self) { index in
                            row(col1: "\(index + 1). \(self.coronaStore.currentCases[index].name)",
                                col2: self.coronaStore.currentCases[index].confirmedStr,
                                col3: self.coronaStore.currentCases[index].deathsStr,
                                col4: self.coronaStore.currentCases[index].cfrStr)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                                .background(self.coronaStore.currentCases[index].name == "Russia" ? Color.systemBlue.opacity(0.3) : Color.clear)
                                .background(index.isMultiple(of: 2) ? Color.secondarySystemBackground : .clear)
                                .contextMenu {
                                    Button(action: {
                                        self.prepareHistoryData(for: index)
                                    }) {
                                        HStack {
                                            Text("Show History Chart")
                                            Image(systemName: "waveform.path.ecg")
                                        }
                                    }
                            }
                            .onTapGesture {
                                self.prepareHistoryData(for: index)
                            }
                            .sheet(isPresented: self.$showLineChart) {
                                CasesLineChartView(forAllCountries: false)
                                    .environmentObject(self.coronaStore)
                                    .environmentObject(self.settings)
                            }
                        }
                    }
                }
            }
            .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
                //            .padding([.horizontal, .top])
                .navigationBarTitle("Cases Data")
                .navigationBarItems(trailing: Button("Done") {
                    self.presentation.wrappedValue.dismiss()
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    //  MARK: FINISH THIS
    //  стоит перенести в модель?
    //  маркер по названию или индексу? - что лучше
    //  также используется в FlexibleCasesChart()
    func prepareHistoryData(for index: Int) {
        self.coronaStore.selectedCountry = self.coronaStore.currentCases[index].name
        self.showLineChart = true
    }
}

struct CasesTableView_Previews: PreviewProvider {
    static var previews: some View {
        CasesTableView()
            .environmentObject(CoronaStore())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
