//
//  ExtractedView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct ExtractedView: View {
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var qty: Int = 3
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .custom, vertical: .top)) {
            GeometryReader { geo in
                ForEach(0..<self.qty, id: \.self) { item in
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
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.qty = 5
            }
        }
    }
}

struct ExtractedView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedView()
    }
}
