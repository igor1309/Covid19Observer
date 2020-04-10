//
//  AxisY.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct AxisY: View {
    let seriesMax: Int
    let steps: Int
    
    init(seriesMax: Int, steps: Int) {
        self.seriesMax = seriesMax
        self.steps = steps
    }
    
    init(axisY: Axis) {
        self.seriesMax = Int(axisY.top)
        self.steps = axisY.steps
    }
    
    @State private var width: CGFloat = 50
    
    private func axisLabel(geoHeight: CGFloat, line: Int) -> some View {
        Text("\(line * self.seriesMax / self.steps)")
            .foregroundColor(line == 0 ? .clear : .secondary)
            .font(.caption)
            .offset(y: geoHeight - CGFloat(line) * geoHeight / CGFloat(steps))
            .fixedSize(horizontal: true, vertical: false)
            .widthPref()
            .frame(width: self.width, alignment: .trailing)
    }
    
    var body: some View {
        VStack {
            if steps > 0 {
                GeometryReader { geo in
                    ForEach(0..<self.steps + 1, id: \.self) { line in
                        
                        self.axisLabel(geoHeight: geo.size.height, line: line)
                    }
                }
                .onPreferenceChange(WidthPref.self) { self.width = $0 }
                .frame(width: self.width)
                .fixedSize(horizontal: true, vertical: false)
            } else {
                /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
            }
        }
    }
}


struct AxisY_Previews: PreviewProvider {
    static var series = [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236]
    
    static var previews: some View {
        HStack {
            //                        Circle()
            //                            .fill(Color.blue)
            //                            .opacity(0.1)
            
            LineGraphShape(series: series)
                .stroke(Color.orange, lineWidth: 2)
            
            AxisY(seriesMax: series.max()!, steps: 10)
                .layoutPriority(1)
                .border(Color.pink)
            
        }
        .border(Color.green)
        .padding()
    }
}
