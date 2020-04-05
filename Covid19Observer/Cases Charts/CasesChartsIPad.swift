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
            CasesHeader()
            
            if coronaStore.cases.isNotEmpty {
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ForEach(CaseDataType.allCases, id: \.self) { type in
                                    Text("\(type.id): \(self.coronaStore.total(for: type))")
                                        .foregroundColor(type.color)
                                        .font(.subheadline)
                                        .padding(.vertical, 6)
                                        .frame(width: max(300, geo.size.width) / (self.sizeClass == .compact ? 1 : CGFloat(CaseDataType.allCases.count)))
                                }
                            }

                            ScrollView(.vertical, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(CaseDataType.allCases, id: \.self) { type in
                                        
                                        CaseChart(
                                            selectedType: type,
                                            isBarsTappable: self.sizeClass == .compact,
                                            /// make iPhone and iPad universal
                                            width: max(300, geo.size.width) / (self.sizeClass == .compact ? 1 : CGFloat(CaseDataType.allCases.count))
                                        )
                                    }
                                }
                            }
                        }
                    }
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
