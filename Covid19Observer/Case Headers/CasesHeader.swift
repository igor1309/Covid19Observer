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
        HStack {
            VStack {
                Text("\(coronaStore.coronaOutbreak.totalCases)")
                    .font(.subheadline)
                Text("confirmed")
            }
            .foregroundColor(.systemYellow)
            
            Spacer()
            //  MARK: FIX THIS
            //
            VStack {
            Text("\(1_000)")
            .font(.subheadline)
            Text("new")
            }
            .foregroundColor(.systemOrange)
            
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
