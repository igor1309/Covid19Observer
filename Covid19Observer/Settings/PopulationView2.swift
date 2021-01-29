//
//  PopulationView2.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine
import SwiftPI

struct PopulationView2: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var populationStore: PopulationStore
    
    @State private var showLineChart = false
    
    private var header: some View {
        let worldPopulation = populationStore.populationOf(country: nil)
        
        return HStack(alignment: .firstTextBaseline) {
            Text("Population")
                .font(.title)
                .padding(.top)
            Text(worldPopulation.formattedGrouped)
                .foregroundColor(.tertiary)
                .font(.subheadline)
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .imageScale(.small)
                .foregroundColor(.tertiary)
            
            TextField("Type to search", text: $populationStore.query, onCommit:  {
                print(self.$populationStore.query)
            })
            
            populationStore.query.isNotEmpty
                ? Button(action: {
                    self.populationStore.query = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.tertiary)
                    }
                : nil
        }
        .padding(6)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.tertiary, lineWidth: 0.5)
        )
    }
    
    private var picker: some View {
        Picker(selection: $populationStore.selectedFilter, label: Text("Filter Options")) {
            ForEach(PopulationStore.FilterKind.allCases, id: \.self) { option in
                Text(option.id).tag(option)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private func row(for item: PopulationElement) -> some View {
        func togglePrimeCountry() {
            if isInSelected {
                let index = self.settings.primeCountries.firstIndex { $0.name == item.id }!
                self.settings.primeCountries.remove(at: index)
            } else {
                self.settings.primeCountries.append(Country(name: item.id, iso2: item.iso2))
            }
        }
        
        let isInSelected = settings.primeCountries.map { $0.name }.contains(item.id)
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.combinedKey)
                
                Spacer()
                
                Text("\(item.population ?? 0)")
                    .font(.subheadline)
            }
            
            HStack {
                Text("iso2: \(item.iso2) | iso3 \(item.iso3) | uid \(item.uid) | fips \(item.fips ?? 0)")
                    .foregroundColor(.tertiary)
                    .font(.footnote)
                
                Spacer()
                
                if populationStore.selectedFilter == .countries {
                    Image(systemName: isInSelected ? "star.fill" : "star")
                        .foregroundColor(isInSelected ? .systemOrange : .secondary)
                        .font(.footnote)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.showChart(item)
        }
        .contextMenu {
            Button(action: {
                self.showChart(item)
            }) {
                Image(systemName: "waveform.path.ecg")
                Text("Show COVID-19 Chart")
            }
            Button(action: {
                //  MARK: FINISH THIS - SHOW ON A MAP
                //
            }) {
                Image(systemName: "map")
                Text("Show on the Map")
            }
            
            /// показывать меню добавления удаления стран из особого списка только при показе списка стран
            if populationStore.selectedFilter == .countries {
                Button(action: {
                    togglePrimeCountry()
                }) {
                    Image(systemName: isInSelected ? "star" : "star.fill")
                    Text(isInSelected ? "Remove from Selected" : "Add to Selected")
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            header
            searchField
                .padding(.horizontal)
            picker
            
            List {
                ForEach(populationStore.queryResult) { item in
                    self.row(for: item)
                }
            }
            .sheet(isPresented: self.$showLineChart) {
                CountryLineChartSheet()
                    .environmentObject(self.coronaStore)
                    .environmentObject(self.settings)
            }
        }
    }
    
    func showChart(_ item: PopulationElement) {
        //  MARK: FINISH THIS FOR TERRITORIES THAT ARE NOT COUNTRIES
        //
        
        let isThereSmthToShow = self.coronaStore.confirmedHistory.series(for: item.countryRegion).max() ?? 0 > 0
        
        if isThereSmthToShow {
            self.coronaStore.selectedCountry = item.countryRegion
            self.showLineChart = true
        }
    }
}

struct PopulationView2_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            PopulationView2()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
