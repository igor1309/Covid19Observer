//
//  SelectedCountriesView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 15.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct SelectedCountriesView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    @Environment(\.editMode) var editMode
    
    @State private var showPopulation = false
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    editMode?.wrappedValue == .active
                        ? Button("Done") {
                            withAnimation {
                                self.editMode?.wrappedValue = .inactive
                            }
                        }
                        .padding(.leading)
                        .offset(y: -16)
                        : nil
                    
                    Spacer()
                    
                    Button(action: {
                        self.showPopulation = true
                    }) {
                        Image(systemName: "plus")
                            .frame(width: 44, height: 44)
                    }
                    .offset(y: -16)
                    .sheet(isPresented: $showPopulation) {
                        PopulationView()
                            .environmentObject(self.coronaStore)
                            .environmentObject(self.settings)
                    }
                }
                
                Text("Selected Countries")
                    .font(.title)
            }
            .padding(.top)
            
            List {
                ForEach(settings.selectedCountries, id: \.self) { country in
                    HStack(alignment: .firstTextBaseline) {
                        Text(country.name)
                        Spacer()
                        Text(country.iso2)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        withAnimation {
                            self.editMode?.wrappedValue = .active == self.editMode?.wrappedValue ? .inactive : .active
                        }
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        settings.selectedCountries.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        settings.selectedCountries.remove(atOffsets: offsets)
    }
}

struct SelectedCountriesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            SelectedCountriesView()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
