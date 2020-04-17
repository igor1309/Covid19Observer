//
//  CountryPicker.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryPicker: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var showSelectedCountries = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    Text("Prime Countries")
                    
                    Button("(edit)") {
                        self.showSelectedCountries = true
                    }
                    .sheet(isPresented: $showSelectedCountries) {
                        SelectedCountriesView()
                            .environmentObject(self.coronaStore)
                            .environmentObject(self.settings)
                    }
                }
                
                PrimeCountryPicker(selection: $coronaStore.selectedCountry)
                Divider()
                
                //                Spacer()
                
                Text("All Countries")
                
                Picker(selection: $coronaStore.selectedCountry, label: Text("Selected Country")) {
                    ForEach(coronaStore.countryRegions, id: \.self) { countryRegion in
                        //  ForEach(coronaStore.currentCases.provinceStateCountryRegions, id: \.self) { countryRegion in
                        Text(countryRegion)
                    }
                }
                .labelsHidden()
                
                Spacer()
                
            }
            .padding([.horizontal, .top])
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
            .environmentObject(CoronaStore())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
