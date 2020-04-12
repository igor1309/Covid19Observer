//
//  PrimeCountryPicker.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct PrimeCountryPicker: View {
    @Binding var selection: String

    var body: some View {
        Picker(selection: $selection, label: Text("Selected Country")) {
            ForEach(PrimeCountries.allCases, id: \.self)  { country in
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
        PrimeCountryPicker(selection: $selection)
    }
}
