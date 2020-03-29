//
//  CasesHeaderButton.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesHeaderButton: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @State private var showTable = false
    
    var body: some View {
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
    }
}

struct CasesHeaderButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CasesHeaderButton()
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
