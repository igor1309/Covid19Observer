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
    
    var numberPicker: some View {
        Picker(selection: $settings.initialDoublingNumber, label: Text("Initial Number")) {
                ForEach(DoublingModel.initialNumbers, id: \.self) { no in
                    Text(no.formattedGrouped)
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
    }
    
    var compactHeader: some View {
        VStack(alignment: .leading) {
            Text("Initial Number")
            
            numberPicker
        }
    }
    
    var regularHeader: some View {
        HStack {
            Text("Initial Number")
            
            numberPicker
                .frame(maxWidth: 375)
        }
    }
    
    var compactTableTitle: some View {
        HStack {
            Spacer()
            
            Text("Doubling Time, days")
                .foregroundColor(.systemTeal)
                .font(.footnote)
                .padding(.trailing, 8)
        }
    }
    
    var regularTableTitle: some View {
        Group {
            Spacer()
            
            Text("Doubling Time, days")
                .foregroundColor(.systemTeal)
                .font(.footnote)
                .padding(.top)
                .padding(.trailing, 8)
        }
    }
    
    @State private var showWiki = false
    var body: some View {
        NavigationView {
            VStack {
                if sizeClass == .compact {
                    VStack(alignment: .leading) {
                        compactHeader
                        
                        Divider()
                            .padding(.vertical)
                        
                        compactTableTitle
                        
                        Table(headers: DoublingModel.rowHeaders(),
                              cells: DoublingModel.DoublingCells(initialNumber: settings.initialDoublingNumber))
                        
                        Divider()
                            .padding(.vertical)
                        
                        Button(action: {
                            self.showWiki = true
                        }) {
                            Text("The doubling time is time it takes for a population to double in size/value. It is applied to population growth, inflation, resource extraction, consumption of goods, compound interest…")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        .sheet(isPresented: $showWiki) {
                            WikiQuoteView()
                        }
                        
                        Spacer()
                    }
                } else {
                    VStack {
                        regularHeader
                        
                        regularTableTitle
                        
                        Table(headers: DoublingModel.rowHeaders(),
                              cells: DoublingModel.DoublingCells(initialNumber: settings.initialDoublingNumber))
                        
                        Divider()
                            .padding(.vertical)
                        
                        WikiQuoteView()
                        
                        Spacer()
                    }
                    
                }
            }
            .padding()
            .navigationBarTitle("Doubling Time")
            .navigationBarItems(trailing: Button("Done") {
                self.presentation.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DoublingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        DoublingTimeView()
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
