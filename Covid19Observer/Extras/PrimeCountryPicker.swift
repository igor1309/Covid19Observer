//
//  PrimeCountryPicker.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct PrimeCountryPicker: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @Binding var selection: String
    
    var body: some View {
        let country = Binding<Country>(
            get: {
                guard let iso2 = self.store.countriesWithIso2[self.selection] else { return Country(name: self.selection, iso2: "") }
                return Country(name: self.selection, iso2: iso2)
        },
            set: {
                self.selection = $0.name
        })
        
        return Picker(selection: country, label: Text("Selected Country")) {
            ForEach(settings.primeCountries, id: \.self)  { country in
                Text(country.iso2).tag(country.name)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct PrimeCountryPicker_Previews: PreviewProvider {
    @State static var selection = "Russia"
    
    static var previews: some View {
        NavigationView {
            PrimeCountryPicker(selection: $selection)
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
