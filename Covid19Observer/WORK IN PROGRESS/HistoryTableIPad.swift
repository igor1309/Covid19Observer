//
//  HistoryTableIPad.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 09.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Row: View {
    var country: String
    var series: [Int]
    
    var body: some View {
        //        ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            Text(country)
                .frame(width: 120, alignment: .leading)
            
            ForEach(series.indices) { ix in
                Text("\(self.series[ix])")
                    .frame(width: 56)
                    .background(ix % 2 == 0 ? .clear : Color(UIColor.tertiarySystemFill))
            }
        }
        .font(.caption)
    }
    //    }
}

struct HistoryTableIPad: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ScrollView(.vertical) {
                    VStack {
                        //                ScrollView(.horizontal) {
                        ForEach(coronaStore.confirmedHistory.countryRows) { countryCase in
                            Row(country: countryCase.name, series: countryCase.series)
                        }
                        //            }
                    }
                }
            }
        }
    }
}

struct HistoryTableIPad_Previews: PreviewProvider {
    static var previews: some View {
        HistoryTableIPad()
            .environmentObject(CoronaStore())
    }
}
