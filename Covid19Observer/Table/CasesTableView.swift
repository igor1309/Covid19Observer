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
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var showLineChart = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(coronaStore.cases.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1). \(self.coronaStore.cases[index].name)")
                                    .padding(.leading, 6)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                
                                Group {
                                    Text(self.coronaStore.cases[index].confirmedStr)
                                        .foregroundColor(.systemYellow)
                                        .padding(.trailing, 6)
                                        .widthPreference(column: 1)
                                        .frame(width: self.columnWidths[1], alignment: .trailing)
                                    
                                    Text(self.coronaStore.cases[index].deathsStr)
                                        .foregroundColor(.systemRed)
                                        .padding(.leading, 12)
                                        .padding(.trailing, 6)
                                        .widthPreference(column: 2)
                                        .frame(width: self.columnWidths[2], alignment: .trailing)
                                }
                                .font(.system(.subheadline, design: .monospaced))
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .background(index.isMultiple(of: 2) ? Color.secondarySystemBackground : .clear)
                            .contextMenu {
                                Button(action: {
                                    self.prepareJHData(for: index)
                                }) {
                                    HStack {
                                        Text("Show History Chart")
                                        Image(systemName: "waveform.path.ecg")
                                    }
                                }
                            }
                            .onTapGesture {
                                self.prepareJHData(for: index)
                            }
                            .sheet(isPresented: self.$showLineChart) {
                                CasesLineChartView()
                                    .environmentObject(self.coronaStore)
                            }
                        }
                    }
                    .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
                }
            }
                //            .padding([.horizontal, .top])
                .navigationBarTitle("Confirmed & Deaths")
            //            .navigationBarItems(trailing: Button("Done") {
            //                self.presentation.wrappedValue.dismiss()
            //            })
        }
    }
    
    //  MARK: FINISH THIS
    //  стоит перенести в модель?
    //  маркер по названию или индексу? - что лучше
    //  также используется в TopCasesHBarChart()
    func prepareJHData(for index: Int) {
        self.coronaStore.selectedCountry = self.coronaStore.cases[index].name
        self.showLineChart = true
    }
}

struct CasesTableView_Previews: PreviewProvider {
    static var previews: some View {
        CasesTableView()
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
