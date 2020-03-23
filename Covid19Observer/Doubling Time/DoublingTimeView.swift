//
//  DoublingTimeView.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct DoublingTimeView: View {
    @EnvironmentObject var doublingData: DoublingData
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Initial Number")
                    
                    Picker(selection: $doublingData.initialNumber, label: Text("Initial Number")) {
                        ForEach(DoublingModel.initialNumbers, id: \.self) { no in
                            Text(no.formattedGrouped)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Divider()
                    .padding(.vertical)
                
                HStack {
                    Spacer()
                    
                    Text("Doubling Time, days")
                        .foregroundColor(.systemTeal)
                        .font(.footnote)
                        .padding(.trailing, 8)
                }
                
                Table(headers: DoublingModel.rowHeaders(),
                      cells: DoublingModel.DoublingCells(initialNumber: doublingData.initialNumber))
                
                Divider()
                    .padding(.vertical)
                
                NavigationLink(destination: WikiQuoteView()) {
                    Text("The doubling time is time it takes for a population to double in size/value. It is applied to population growth, inflation, resource extraction, consumption of goods, compound interest…")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Doubling Time")
        }
    }
}

struct DoublingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        DoublingTimeView()
            .environmentObject(DoublingData())
    }
}
