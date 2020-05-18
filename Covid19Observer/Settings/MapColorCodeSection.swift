//
//  MapColorCodeSection.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MapColorCodeSection: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    let lowerLimits: [Int] = [100, 500, 1_000, 5_000, 10_000]
    
    func colorCapsule(item: Int) -> some View {
        Capsule()
            .foregroundColor(Color(MapOptions.colorCode(for: item)))
            .padding(.horizontal, self.settings.mapOptions.lowerLimit == item ? 6 : 8)
            .padding(self.settings.mapOptions.lowerLimit == item ? 0 : 3)
            .frame(height: 16)
            .overlay(
                Capsule()
                    .stroke(self.settings.mapOptions.lowerLimit == item ? Color.primary : .clear, lineWidth: 2)
                    .padding(.horizontal, 6)
        )
    }
    
    var body: some View {
        Section(header: Text("Lower Limit for Map Filter".uppercased()),
                footer: Text("Select number (color) as a lower limit to filter pins on the map.")
        ) {
            Group {
                HStack {
                    ForEach(lowerLimits, id: \.self) { item in
                        self.colorCapsule(item: item)
                            .onTapGesture {
                                self.settings.mapOptions.lowerLimit = item
                        }
                    }
                }
                
                Picker(selection: $settings.mapOptions.lowerLimit, label: Text("Lower Limit")
                ) {
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

struct MapColorCodeSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                MapColorCodeSection()
            }
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
