//
//  CaseTypePicker.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseTypePicker: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        Picker(selection: $store.caseType, label: Text("Select by Provincee or Country")) {
            ForEach(CaseType.allCases, id: \.self) { type in
                Text(type.id).tag(type)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct CaseTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CaseTypePicker()
                .padding()
        }
        .environmentObject(Store())
        .environment(\.colorScheme, .dark)
    }
}
