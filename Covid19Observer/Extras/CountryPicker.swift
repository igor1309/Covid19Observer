//
//  CountryPicker.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryPicker: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                    ForEach(coronaStore.countryRegions, id: \.self) { countryRegion in
                        //  ForEach(coronaStore.cases.provinceStateCountryRegions, id: \.self) { countryRegion in
                        Text(countryRegion)
                    }
                }
                .labelsHidden()
                
                Spacer()
                Divider()
                
                Text("Prime Countries")
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                    ForEach(PrimeCountries.allCases, id: \.self)  { country in
                        Text(country.name).tag(country.name)
                    }
                }
                .labelsHidden()
                
                Spacer()
            }
            .navigationBarTitle("Select Country")
            .navigationBarItems(trailing: Button("Done") {
                self.presentation.wrappedValue.dismiss()
            })
        }
    }
}

struct CountryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CountryPicker()
    }
}
