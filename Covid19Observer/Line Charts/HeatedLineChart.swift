//
//  HeatedLineChart.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct HeatedLineChart: View {
    let series: [Int]
    let numberOfGridLines: Int
    let lineWidth: CGFloat = 4
    
    let temperetureGradient = Gradient(colors: [
        .purple,
        Color(red: 0, green: 0, blue: 139.0/255.0),
        .blue,
        Color(red: 30.0/255.0, green: 144.0/255.0, blue: 1.0),
        Color(red: 0, green: 191/255.0, blue: 1.0),
        Color(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0),
        .green,
        .yellow,
        .orange,
        Color(red: 1.0, green: 140.0/255.0, blue: 0.0),
        .red,
        Color(red: 139.0/255.0, green: 0.0, blue: 0.0)
    ])
    
    @State private var animated = false
    
    var body: some View {
        VStack {
            if series.isNotEmpty {
                HStack {
                    ZStack {
                        GraphGridShape(series: series, numberOfGridLines: numberOfGridLines)
                            .stroke(Color.systemGray6)
                        
                        LineGraphShape(series: series)
                            .trim(to: animated ? 1 : 0)
                            .stroke(LinearGradient(gradient: temperetureGradient,
                                                   startPoint: .bottom,
                                                   endPoint: .top),
                                    style: StrokeStyle(lineWidth: lineWidth,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                    }
                    
                    AxisY(series: series, numberOfGridLines: numberOfGridLines)
                }
                .padding(lineWidth / 2)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            self.animated = true
                        }
                    }
                }
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
        }
    }
}

struct HeatedLineChart_Previews: PreviewProvider {
    static var previews: some View {
        HeatedLineChart(series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236],
                        numberOfGridLines: 10)
//            .border(Color.pink)
            .padding()
    }
}
