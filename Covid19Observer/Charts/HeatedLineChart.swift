//
//  HeatedLineChart.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct HeatedLineChart: View {
    let series: [Int]
    let numberOfGridLines: Int
    
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
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    var body: some View {
        HStack {
            ZStack {
                LineGraphGridShape(series: series, numberOfGridLines: numberOfGridLines)
                    .stroke(Color.systemGray6)

                LineGraph(series: series)
                    .trim(to: animated ? 1 : 0)
                    .stroke(LinearGradient(gradient: temperetureGradient,
                                           startPoint: .bottom,
                                           endPoint: .top),
                            lineWidth: 4)
                
                 .animation(Animation.easeInOut(duration: 2))
                
                ZStack(alignment: Alignment(horizontal: .custom, vertical: .top)) {
                    GeometryReader { geo in
                        ForEach(0..<10, id: \.self) { item in
                            Text("\(Int(pow(2, Double(item))))")
                                .border(Color.pink)
                                .offset(y: geo.size.height - CGFloat(item) * geo.size.height / 10)
                                .alignmentGuide(.custom) { d in d.width}
                                .widthPreference(column: -1)
                                .frame(width: self.columnWidths[-1], alignment: .trailing)
                        }
                    }
                    .frame(width: self.columnWidths[-1], alignment: .trailing)
                    .border(Color.pink)
                }
                .background(Color.green.opacity(0.2))
                .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }

                ZStack {
                    //  VStack(alignment: .custom) {
                    GeometryReader { geo in
                        ForEach(0..<11) { line in
//                            Text("text")
                            Text("\(line * (self.series.max() ?? 0) / self.numberOfGridLines)")
                                .foregroundColor(line == 0 ? .clear : .secondary)
                                .font(.caption)
                                .widthPreference(column: -1)
                                .frame(width: self.columnWidths[-1], alignment: .trailing)
                                 .alignmentGuide(.custom) { d in d.width}
                                .offset(
                                      x: geo.size.width - 50,
                                    y: geo.size.height - CGFloat(line) * geo.size.height / CGFloat(self.numberOfGridLines) + 2)
                        }
                    }
                }
                .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
                
//                ExtractedView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    self.animated = true
                }
            }
        }
    }
}

struct HeatedLineChart_Previews: PreviewProvider {
    static var previews: some View {
        HeatedLineChart(series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236],
                        numberOfGridLines: 10)
    }
}
