//
//  CasesHeader.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesHeader: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var showTable = false
    
    var body: some View {
        HStack(spacing: 6) {
            Group {
                VStack {
                    Text("\(coronaStore.coronaOutbreak.totalCases)")
                        .font(.subheadline)
                    Text("confirmed")
                }
                .foregroundColor(CaseDataType.confirmed.color)
                
                Spacer()
                VStack {
                    Text("\(coronaStore.coronaOutbreak.totalNewConfirmed)")
                        .font(.subheadline)
                    Text("new")
                }
                .foregroundColor(CaseDataType.new.color)
                
                Spacer()
                VStack {
                    Text("\(coronaStore.coronaOutbreak.totalCurrentConfirmed)")
                        .font(.subheadline)
                    Text("current")
                }
                .foregroundColor(CaseDataType.current.color)
            }
            
            Group {
                Spacer()
                VStack {
                    Text("\(coronaStore.coronaOutbreak.totalDeaths)")
                        .font(.subheadline)
                    Text("deaths")
                }
                .foregroundColor(CaseDataType.deaths.color)
                
                Spacer()
                VStack {
                    Text("\(coronaStore.worldCaseFatalityRate.formattedPercentageWithDecimals)")
                        .font(.subheadline)
                    Text("CFR")
                }
                .foregroundColor(CaseDataType.cfr.color)
                
                Spacer()
                VStack {
                    Text("\(coronaStore.coronaOutbreak.totalRecovered)")
                        .font(.subheadline)
                    Text("recovered")
                }
                .foregroundColor(.systemGreen)
            }
            
            Group {
                Spacer()
                Button(action: {
                    self.showTable = true
                }) {
                    VStack {
                        Text("Table".uppercased())
                            .font(.subheadline)
                        Text("details")
                    }
                }
                .sheet(isPresented: $showTable) {
                    CasesTableView()
                        .environmentObject(self.coronaStore)
                }
                .foregroundColor(.secondary)
                
                Spacer()
//                Button(action: {
                    //  MARK: FIX THIS
                    //  app crashes — data changes but gradually
                    //  state is changing while charts are drawing
                    //  need some flag to signal update finish
                    //
                    //                    self.coronaStore.updateCasesData() { _ in }
                    //                    self.coronaStore.updateHistoryData { }
//                }) {
                    VStack {
                        Text("\(coronaStore.timeSinceCasesUpdateStr) ago")
                            .font(.subheadline)
                        Text("updated")
                    }
                    .foregroundColor(coronaStore.isCasesDataOld ? .systemRed : .secondary)
                    .opacity(0.8)
//                }
            }
        }
        .font(.caption)
        .padding(.horizontal, 6)
    }
}

struct CasesHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                CasesHeader()
            }
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
