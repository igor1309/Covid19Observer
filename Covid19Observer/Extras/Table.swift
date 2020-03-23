//
//  Table.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct Table: View {
    var headers: [String]
    var cells: [[String]]
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    let height: CGFloat = 32
    
    func cellFor(row: Int, col: Int) -> some View {
        Text(cells[row][col])
            .foregroundColor(row == 0 ? .systemOrange : .primary)
            .widthPreference(column: col)
            .frame(width: columnWidths[col], height: height, alignment: .trailing)
            //            .frame(width: 64, height: height, alignment: .trailing)
            .padding(.leading, 12)
            .padding(.trailing, 3)
            .background(row.isMultiple(of: 2) ? Color.quaternarySystemFill : .clear)
        //                    .border(Color.pink)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(headers.indices, id: \.self) { row in
                    Text(self.headers[row])
                        //                        .frame(width: self.columnWidths[-1], height: self.height, alignment: .leading)
                        .frame(width: 52, height: self.height, alignment: .leading)
                        .padding(.leading, 4)
                        .padding(.trailing, 6)
                        .background(row % 2 == 0 ? Color.quaternarySystemFill : .clear)
                    //                    .border(Color.pink)
                }
            }
            .foregroundColor(.systemOrange)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(cells.indices, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(self.cells[row].indices, id: \.self) { col in
                                self.cellFor(row: row, col: col)
                            }
                        }
                    }
                }
            }
            .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
        }
        .font(.footnote)
    }
}
struct Table_Previews: PreviewProvider {
    static var previews: some View {
        Table(headers: ["head 1", "head 2"], cells: [["fkgjh", "aksjdghv"], ["asf", "s"]])
        .padding()
    }
}
