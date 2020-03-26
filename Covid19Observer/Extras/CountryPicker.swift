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
//            List {
                Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                    ForEach(coronaStore.countryRegions, id: \.self) { countryRegion in
                        //  ForEach(coronaStore.cases.provinceStateCountryRegions, id: \.self) { countryRegion in
                        Text(countryRegion)
                    }
                }
                .labelsHidden()
//            }
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