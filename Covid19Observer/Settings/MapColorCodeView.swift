//
//  MapColorCodeView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MapColorCodeView: View {
    @EnvironmentObject var store: Store
    
    let lowerLimits: [Int] = [100, 500, 1_000, 5_000, 10_000]
    
    var body: some View {
        Section(header: Text("Lower Limit for Map Filter".uppercased()),
                footer: Text("Select number (color) as a lower limit to filter pins on the map.")
        ) {
            Group {
                HStack {
                    ForEach(lowerLimits, id: \.self) { item in
                        Capsule()
                            //  .foregroundColor(Color(self.store.colorCode(for: item)))
                            .foregroundColor(Color(MapOptions.colorCode(for: item)))
                            .padding(.horizontal, self.store.mapOptions.lowerLimit == item ? 6 : 8)
                            .padding(self.store.mapOptions.lowerLimit == item ? 0 : 3)
                            .frame(height: 16)
                            .overlay(
                                Capsule()
                                    .stroke(self.store.mapOptions.lowerLimit == item ? Color.primary : .clear, lineWidth: 2)
                                    .padding(.horizontal, 6)
                        )
                            .onTapGesture {
                                self.store.mapOptions.lowerLimit = item
                        }
                    }
                }
                
                Picker(selection: $store.mapOptions.lowerLimit, label: Text("Select Top Qty")) {
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
        .environmentObject(Store())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
