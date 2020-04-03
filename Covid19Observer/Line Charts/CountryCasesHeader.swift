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
                Text("\(coronaStore.selectedCountryOutbreak.confirmed)")
                    .font(.headline)
                Text("confirmed")
            }
            .foregroundColor(CaseDataType.confirmed.color)
            
            Spacer()
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.newConfirmed)")
                    .font(.headline)
                Text("new")
            }
            .foregroundColor(CaseDataType.new.color)
            
            Spacer()
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.currentConfirmed)")
                    .font(.headline)
                Text("current")
            }
            .foregroundColor(CaseDataType.current.color)
            
            
            Spacer()
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.deaths)")
                    .font(.headline)
                Text("deaths")
            }
            .foregroundColor(CaseDataType.deaths.color)
            
            Spacer()
            VStack {
                Text("\(coronaStore.selectedCountryOutbreak.cfr)")
                    .font(.headline)
                Text("CFR")
            }
            .foregroundColor(CaseDataType.cfr.color)
        }
        .font(.caption)
    }
}

struct CountryCasesHeader_Previews: PreviewProvider {
    static var previews: some View {
        CountryCasesHeader()
            .environmentObject(CoronaStore())
    }
}
