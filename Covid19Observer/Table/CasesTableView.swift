//
//  CasesTableView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesTableView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaCases: CoronaObservable
    @State private var columnWidths: [Int: CGFloat] = [:]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(coronaCases.cases.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1). \(self.coronaCases.cases[index].name)")
                                    .padding(.leading, 6)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                
                                Group {
                                Text(self.coronaCases.cases[index].confirmedStr)
                                    .foregroundColor(.systemYellow)
                                    .padding(.trailing, 6)
                                    .widthPreference(column: 1)
                                    .frame(width: self.columnWidths[1], alignment: .trailing)
                                
                                Text(self.coronaCases.cases[index].deathsStr)
                                    .foregroundColor(.systemRed)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 6)
                                    .widthPreference(column: 2)
                                    .frame(width: self.columnWidths[2], alignment: .trailing)
                            }
                            .font(.system(.subheadline, design: .monospaced))
                            }
                            .padding(.vertical, 10)
                            .background(index.isMultiple(of: 2) ? Color.secondarySystemBackground : .clear)
                        }
                    }
                    .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
                }
            }
            .padding(.horizontal)
            .navigationBarTitle("Confirmed & Deaths")
            .navigationBarItems(trailing: Button("Done") {
                self.presentation.wrappedValue.dismiss()
            })
        }
    }
}

struct CasesTableView_Previews: PreviewProvider {
    static var previews: some View {
        CasesTableView()
            .environmentObject(CoronaObservable())
            .environment(\.colorScheme, .dark)
    }
}
