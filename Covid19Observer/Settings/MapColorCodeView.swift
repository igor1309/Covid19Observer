//
//  MapColorCodeView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MapColorCodeView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    let lowerLimits: [Int] = [100, 500, 1_000, 5_000, 10_000]
    
    var body: some View {
        Section(header: Text("Map Color Code".uppercased()),
                footer: Text("Select number (color) as a lower limit to filter pins on the map.")
        ) {
            //                            VStack(alignment: .leading, spacing: 12) {
            Group {
                Text("Lower Limit for Map Filter")
                    .foregroundColor(coronaStore.filterColor)
                    .padding(.trailing, 64)
                
                HStack {
                    ForEach(lowerLimits, id: \.self) { item in
                        Capsule()
                            .foregroundColor(Color(self.coronaStore.colorCode(for: item)))
                            .padding(.horizontal, self.coronaStore.mapFilterLowerLimit == item ? 6 : 8)
                            .padding(self.coronaStore.mapFilterLowerLimit == item ? 0 : 3)
                            .frame(height: 16)
                            .overlay(
                                Capsule()
                                    .stroke(self.coronaStore.mapFilterLowerLimit == item ? Color.primary : .clear, lineWidth: 2)
                                    .padding(.horizontal, 6)
                        )
                            .onTapGesture {
                                self.coronaStore.mapFilterLowerLimit = item
                        }
                    }
                }
                
                Picker(selection: $coronaStore.mapFilterLowerLimit, label: Text("Select Top Qty")) {
                    ForEach(lowerLimits, id: \.self) { qty in
                        Text("\(qty)").tag(qty)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.vertical, 2)
        }
    }
}

struct MapColorCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                MapColorCodeView()
            }
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}