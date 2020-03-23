//
//  AxisY.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct AxisY: View {
    let series: [Int]
    let numberOfGridLines: Int
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ForEach(0..<self.numberOfGridLines + 1, id: \.self) { line in
                    Text("\(line * (self.series.max() ?? 0) / self.numberOfGridLines)")
                        .foregroundColor(line == 0 ? .clear : .secondary)
                        .font(.caption)
                        .offset(y: geo.size.height - CGFloat(line) * geo.size.height / 10)
                        .widthPreference(column: -1)
                        .frame(width: self.columnWidths[-1], alignment: .trailing)
                }
            }
        }
        .frame(width: self.columnWidths[-1], alignment: .trailing)
        .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
    }
}

struct AxisY_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .opacity(0.1)
            
            AxisY(series:            [833,977,1261,1766,2337,3150,3736,4335,5186,5621,6088,6593,7041,7314,7478,7513,7755,7869,7979,8086,8162,8236],
            numberOfGridLines: 10)
                .border(Color.pink)
        }
    }
}
