//
//  SwipeableCasesCharts.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 02.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI


//  MARK: - FINISH if SwiftUI…
//  Looks like heavy computation (CPU usage)
//  Crashes with data update
//
struct SwipeableCasesCharts: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var coronaStore: CoronaStore
    
    @State private var offset: CGSize = .zero
    @State private var savedOffset: CGSize = .zero
    
    var body: some View {
        VStack {
            
            if coronaStore.coronaByCountry.cases.isNotEmpty {
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ForEach(CaseDataType.allCases, id: \.self) { type in
                                    Text(type.id)
                                        .foregroundColor(type.color)
                                        .font(.headline)
                                        .padding(.vertical, 6)
                                        .frame(width: max(300, geo.size.width) / (self.sizeClass == .compact ? 1 : CGFloat(CaseDataType.allCases.count)))
                                }
                            }
                            .offset(self.offset)
                            .animation(.spring())
                            
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
                            .offset(self.offset)
                            .gesture(
                                DragGesture()
                                    .onChanged {
                                        self.offset.width = self.savedOffset.width + $0.translation.width
                                }
                                .onEnded { v in
                                    /// move: -1, 0, 1
                                    let move = ( 3 * v.translation.width / 2 / geo.size.width).rounded()
                                    self.savedOffset.width += move * geo.size.width
                                    
                                    if self.savedOffset.width > 0 {
                                        self.savedOffset.width = 0
                                    }
                                    if self.savedOffset.width < -geo.size.width * CGFloat(CaseDataType.allCases.count - 1) {
                                        self.savedOffset.width = -geo.size.width * CGFloat(CaseDataType.allCases.count - 1)
                                    }
                                    
                                    self.offset.width = self.savedOffset.width
                                }
                            )
                                .animation(.spring())
                        }
                    }
                }
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
        }
    }
}

struct SwipeableCasesCharts_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableCasesCharts()
            .environmentObject(CoronaStore())
            .environment(\.colorScheme, .dark)
    }
}
