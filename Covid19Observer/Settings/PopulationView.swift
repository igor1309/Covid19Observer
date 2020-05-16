//
//  PopulationView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine
import SwiftPI

struct PopulationView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var settings: Settings
    
    @State private var showLineChart = false
    @State private var selectedCountry = Country(name: "", iso2: "")
    
    @State private var searchText = ""
    
    @State private var selectedFilter = FilterKind.countries
    
    private enum FilterKind: String, CaseIterable, Hashable {
        case countries = "Countries"
        case us = "US+"
        case canada = "Canada+"
        case china = "China+"
        
        var id: String { rawValue }
    }
    
    private func filterFunc(_ item: PopulationElement) -> Bool {
        let searchCondition = searchText.count > 2
            ? item.countryRegion.lowercased().contains(searchText.lowercased())
            : true
        
        let selection: Bool
        switch selectedFilter {
        case .countries:
            selection = item.uid < 1000
        case .us:
            selection = item.iso3 == "USA" && item.uid <= 84000056
        case .canada:
            selection = item.iso3 == "CAN"
        case .china:
            selection = item.iso3 == "CHN"
        }
        
        return searchCondition && selection
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.tertiary)
            
            TextField("Type to search", text: $searchText) {
                print(self.$searchText)
            }
            
            searchText.isNotEmpty
                ? Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.tertiary)
                    }
                : nil
        }
        .padding(6)
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
        .stroke(Color.tertiary, style: StrokeStyle(lineWidth: 0.5)))
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
                
                if selectedFilter == .countries {
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
            if selectedFilter == .countries {
                Button(action: {
                    togglePrimeCountry()
                }) {
                    Image(systemName: isInSelected ? "star" : "star.fill")
                    Text(isInSelected ? "Remove from Selected" : "Add to Selected")
                }
            }
        }
    }
    
    private var header: some View {
        let worldPopulation = Double(store.populationOf(country: nil))
        
        return HStack(alignment: .firstTextBaseline) {
            Text("Population")
                .font(.title)
                .padding(.top)
            Text(worldPopulation.formattedGrouped)
                .foregroundColor(.tertiary)
                .font(.subheadline)
        }
    }
    
    private var picker: some View {
        Picker(selection: $selectedFilter, label: Text("Filter Options")) {
            ForEach(FilterKind.allCases, id: \.self) { option in
                Text(option.id).tag(option)
            }
        }
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    var body: some View {
        VStack {
            header
            searchField
            picker
            
            List {
                ForEach(store.population.filter { filterFunc($0) }) { item in
                    self.row(for: item)
                }
            }
            .sheet(isPresented: self.$showLineChart) {
                CasesLineChartView(forAllCountries: false)
                    .environmentObject(self.store)
                    .environmentObject(self.settings)
            }
        }
    }
    
    func showChart(_ item: PopulationElement) {
        //  MARK: FINISH THIS FOR TERRITORIES THAT ARE NOT COUNTRIES
        //
        
        let isThereSmthToShow = self.store.confirmedHistory.series(for: item.countryRegion).max() ?? 0 > 0
        
        if isThereSmthToShow {
            self.store.selectedCountry = item.countryRegion
            self.showLineChart = true
        }
    }
}

struct PopulationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            PopulationView()
        }
        .environmentObject(Store())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
