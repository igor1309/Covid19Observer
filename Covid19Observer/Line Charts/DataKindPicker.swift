//
//  DataKindPicker.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct DataKindPicker: View {
    @Binding var selectedDataKind: DataKind
    
    var body: some View {
        Picker(selection: $selectedDataKind, label: Text("Select Data Kind")) {
            ForEach(DataKind.allCases, id: \.self) { kind in
                Text(kind.id).tag(kind)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct DataKindPicker_Previews: PreviewProvider {
    @State static var selectedDataKind: DataKind = .total
    
    static var previews: some View {
        DataKindPicker(selectedDataKind: $selectedDataKind)
            .padding()
    }
}
