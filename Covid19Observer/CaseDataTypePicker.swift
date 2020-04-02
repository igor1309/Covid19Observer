//
//  CaseDataTypePicker.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseDataTypePicker: View {
    @Binding var selection: CaseDataType
    
    var body: some View {
        Picker(selection: $selection, label: Text("Select Confirmed Cases or Deaths")) {
            ForEach(CaseDataType.allCases, id: \.self) { type in
                Text(type.short).tag(type)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
        .padding(.bottom, 4)
    }
}
