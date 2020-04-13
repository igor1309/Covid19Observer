//
//  CountryCasesHeader.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CountryCasesHeader: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    private var countryOutbreak: Outbreak {
        coronaStore.selectedCountryOutbreak
    }
    
    private func item(valueStr: String, name: String, color: Color) -> some View {
        return VStack(spacing: 0) {
            Text(valueStr)
                .font(.subheadline)
            Text(name)
        }
        .foregroundColor(color)
    }
    
    var body: some View {
        let vspacing: CGFloat = 6
        
        return HStack(spacing: 16) {
            VStack(spacing: vspacing) {
                item(valueStr: countryOutbreak.confirmedStr, name: "confirmed", color: CaseDataType.confirmed.color)
                
                item(valueStr: countryOutbreak.deathsStr, name: "deaths", color: CaseDataType.deaths.color)
            }
            
            //            Spacer()
            VStack(spacing: vspacing) {
                item(valueStr: countryOutbreak.confirmedNewStr, name: "new", color: CaseDataType.new.color)
                
                item(valueStr: countryOutbreak.deathsNewStr, name: "new", color: CaseDataType.new.color)
            }
            
            //            Spacer()
            VStack(spacing: vspacing) {
                item(valueStr: countryOutbreak.confirmedCurrentStr, name: "current", color: CaseDataType.current.color)
                
                item(valueStr: countryOutbreak.deathsCurrentStr, name: "current", color: CaseDataType.current.color)
            }
            
            //            Spacer()
            VStack(spacing: vspacing) {
                item(valueStr: countryOutbreak.deathsPerMillionStr, name: "d per 1m", color: CaseDataType.cfr.color)
                
                item(valueStr: countryOutbreak.cfrStr, name: "CFR", color: CaseDataType.cfr.color)
            }
            
            //            Spacer()
            VStack(spacing: vspacing) {
                item(valueStr: coronaStore.confirmedHistory.last(for: coronaStore.selectedCountry).formattedGrouped, name: "last in history", color: .secondary)
                    .background(Color.tertiarySystemBackground)
                
                item(valueStr: coronaStore.confirmedHistory.last(for: coronaStore.selectedCountry).formattedGrouped, name: "last in history", color: .secondary)
                    .background(Color.tertiarySystemBackground)
            }
        }
        .font(.caption)
    }
}

struct CountryCasesHeader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            CountryCasesHeader()
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
