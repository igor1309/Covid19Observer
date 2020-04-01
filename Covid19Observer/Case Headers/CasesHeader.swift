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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
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
                
                Spacer()
                VStack {
                    Text("\(coronaStore.hoursMunutesSinceCasesUpdateStr)/\(coronaStore.hoursMunutesSinceHistoryUpdateStr)")
                        .font(.subheadline)
                    Text("updated")
                }
                .foregroundColor(.secondary)
            }
            .font(.caption)
            .padding(.horizontal, 6)
        }
    }
}

struct CasesHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CasesHeader()
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
