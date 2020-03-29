//
//  CountryCasesHeader.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryCasesHeader: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    var body: some View {
        HStack {
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.totalCasesStr)")
                    .font(.headline)
                Text("confirmed")
            }
            .foregroundColor(.systemYellow)
            
            Spacer()
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.totalDeathsStr)")
                    .font(.headline)
                Text("deaths")
            }
            .foregroundColor(.systemRed)
            
            Spacer()
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.cfrStr)")
                    .font(.headline)
                Text("CFR")
            }
            .foregroundColor(.systemTeal)
        }
        .font(.caption)
        .padding(.horizontal)
    }
}

struct CountryCasesHeader_Previews: PreviewProvider {
    static var previews: some View {
        CountryCasesHeader()
            .environmentObject(CoronaStore())
    }
}
