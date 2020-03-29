//
//  DoublingTimeView.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct DoublingTimeView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            if sizeClass == .compact {
                VStack(alignment: .leading) {
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Initial Number")
                            
                            Picker(selection: $settings.initialNumber, label: Text("Initial Number")) {
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
                    }
                    
                    
                    Table(headers: DoublingModel.rowHeaders(),
                          cells: DoublingModel.DoublingCells(initialNumber: settings.initialNumber))
                    
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
            } else {
                VStack {
                    HStack {
                        Text("Initial Number")
                        
                        Picker(selection: $settings.initialNumber, label: Text("Initial Number")) {
                            ForEach(DoublingModel.initialNumbers, id: \.self) { no in
                                Text(no.formattedGrouped)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Spacer()
                    
                    Text("Doubling Time, days")
                        .foregroundColor(.systemTeal)
                        .font(.footnote)
                        .padding(.top)
                        .padding(.trailing, 8)
                    
                    Table(headers: DoublingModel.rowHeaders(),
                          cells: DoublingModel.DoublingCells(initialNumber: settings.initialNumber))
                    
                    Divider()
                        .padding(.vertical)
                    
                    WikiQuoteView()
                    
                    Spacer()
                }
                
                .padding()
                .navigationBarTitle("Doubling Time")
                //            .navigationBarItems(trailing: Button("Done") {
                //                self.presentation.wrappedValue.dismiss()
                //            })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DoublingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        DoublingTimeView()
            .environmentObject(Settings())
    }
}
