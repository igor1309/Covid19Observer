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
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                    ForEach(coronaStore.history.countryRegions, id: \.self) { countryRegion in
                        //  ForEach(coronaStore.cases.provinceStateCountryRegions, id: \.self) { countryRegion in
                        Text(countryRegion)
                    }
                }
                .labelsHidden()
            }
            .navigationBarTitle("Select Country")
        }
    }
}

struct CountryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CountryPicker()
    }
}
