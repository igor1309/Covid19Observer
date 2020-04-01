//
//  CasesChartsIPad.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesChartsIPad: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var coronaStore: CoronaStore
    
    var body: some View {
        VStack {
            HStack {
                CasesHeader()
//                    .fixedSize(horizontal: true, vertical: false)
            }
            
            if coronaStore.cases.isNotEmpty {
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                HStack {
                                    ForEach(CaseDataType.allCases, id: \.self) { type in
                                        VStack {
                                            Text(type.id)
                                                .foregroundColor(type.color)
                                                .font(.headline)
                                            
                                            CaseChart(
                                                selectedType: type,
                                                isBarsTappable: self.sizeClass == .compact,
                                                /// make iPhone and iPad universal
                                                width: max(300, geo.size.width) / (self.sizeClass == .compact ? 1 : CGFloat(CaseDataType.allCases.count))
                                            )
                                        }
                                    }
        //                            CaseChart(
        //                                selectedType: CaseDataType.deaths,
        //                                isBarsTappable: false,
        //                                width: geo.size.width / 3
        //                            )
        //                            CaseChart(
        //                                selectedType: CaseDataType.cfr,
        //                                isBarsTappable: false,
        //                                width: geo.size.width / 3
        //                            )
                                }
                            }
                        }
                    }
                    .padding(.top, 3)
                }
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
        }
    }
}

struct CasesChartsIPad_Previews: PreviewProvider {
    static var previews: some View {
        CasesChartsIPad()
            .environmentObject(CoronaStore())
    }
}
