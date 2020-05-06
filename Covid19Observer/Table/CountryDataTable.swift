//
//  CountryDataTable.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension Collection {
    func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
        return Array(self.enumerated())
    }
}

struct CountryDataTable: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    var series: [Int]
    
    var body: some View {
        let count = series.count
        
        return NavigationView {
            List {
                ForEach(series.reversed().indices, id: \.self) { index in
                    HStack {
                        Text("(Date TBD!) index: \(index)")
                            .foregroundColor(.systemRed)
                        //                                    .padding(.leading)
                        
                        Spacer()
                        
                        Text("\(self.series[count - 1 - index])")
                        //                                    .padding(.trailing)
                    }
                    .font(.system(.footnote, design: .monospaced))
                    .listRowBackground(Color(index % 2 == 1 ? .secondarySystemBackground : .clear))
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            }
            .navigationBarTitle(Text(coronaStore.selectedCountry), displayMode: .inline)
        }
    }
}

struct CountryDataTable_Previews: PreviewProvider {
    static var previews: some View {
        CountryDataTable(series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236])
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
