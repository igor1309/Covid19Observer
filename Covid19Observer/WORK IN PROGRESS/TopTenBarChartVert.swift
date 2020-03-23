//
//  TopTenBarChartVert.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TopTenBarChartVert: View {
    @EnvironmentObject var coronaCases: CoronaObservable
    
    var body: some View {
        let maxConfirmed = coronaCases.cases.map { $0.confirmed }.max() ?? 1
        
        return VStack {
            if coronaCases.cases.isNotEmpty {
                GeometryReader { geo in
                    HStack(alignment: .bottom) {
                        ForEach(0..<10) { index in
                            VStack {
                                Text(self.coronaCases.cases[index].name)
                                    .font(.footnote)
                                    .background(Color.blue)
                                    .zIndex(1)
                                
                                ZStack(alignment: .top) {
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(Color.systemYellow)
                                            .frame(width: geo.size.width / 10 * 0.8,
                                                   height: geo.size.height * CGFloat(self.coronaCases.cases[index].confirmed) / CGFloat(maxConfirmed))
                                        
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(Color.systemRed)
                                            .frame(width: geo.size.width / 10 * 0.8,
                                                   height: geo.size.height * CGFloat(self.coronaCases.cases[index].deaths) / CGFloat(maxConfirmed))
                                    }
                                    
                                    Text(self.coronaCases.cases[index].confirmedStr)
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .font(.caption)
                                        .rotationEffect(.degrees(-90))
                                    
                                    //                                Text(self.coronaCases.cases[index].name)
                                    //                                    //                                    .rotationEffect(.degrees(-90))
                                    //                                    .frame(width: geo.size.width / 10 * 0.6, height: 150)
                                    //                                    .rotation3DEffect(.degrees(-90), axis: (x: 0, y: 0, z: 1))
                                    //                                    .foregroundColor(.black)
                                    //                                    .truncationMode(.tail)
                                    //                                    .lineLimit(1)
                                    //                                    .font(.caption)
                                    //                                    //                                    .padding(.leading)
                                    ////                                    .zIndex(1)
                                    //
                                    //                                    .border(Color.pink)
                                    
                                    
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
struct TopTenBarChartVert_Previews: PreviewProvider {
    static var previews: some View {
        TopTenBarChartVert()
            .environmentObject(CoronaObservable())
            .environment(\.colorScheme, .dark)
    }
}
