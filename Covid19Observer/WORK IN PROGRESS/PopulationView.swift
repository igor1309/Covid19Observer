//
//  PopulationView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct PopulationView: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var showLineChart = false
    @State private var selectedCountry = ""
    
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    
    @State private var searchText = ""
    
    @State private var selectedFilter = FilterKind.countries
    
    private func filterFunc(_ item: PopulationElement) -> Bool {
        let searchCondition = searchText.count > 2
            ? item.countryRegion.contains(searchText)
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
    
    private enum FilterKind: String, CaseIterable, Hashable {
        case countries = "Countries"
        case us = "US+"
        case canada = "Canada+"
        case china = "China+"
        
        var id: String { rawValue }
    }
    
    var searchField: some View {
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
    
    var body: some View {
        VStack {
            
            Text("Population")
                .font(.title)
                .padding(.top)
            
            searchField
            
            Picker(selection: $selectedFilter, label: Text("Filter Options")) {
                ForEach(FilterKind.allCases, id: \.self) { option in
                    Text(option.id).tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            List {
                ForEach(population.filter { filterFunc($0) } ) { item in
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.combinedKey)
                            
                            Spacer()
                            Text("\(item.population ?? 0)")
                                .font(.subheadline)
                        }
                        
                        Text("iso2: \(item.iso2) | iso3 \(item.iso3) | uid \(item.uid) | fips \(item.fips ?? 0)")
                            .foregroundColor(.tertiary)
                            .font(.footnote)
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
                            Text("Show Chart")
                        }
                    }
                }
            }
            .sheet(isPresented: self.$showLineChart) {
                CasesLineChartView()
                    .padding(.top, 6)
                    .environmentObject(self.coronaStore)
                    .environmentObject(self.settings)
            }
        }
    }
    
    func showChart(_ item: PopulationElement) {
        //  MARK: FINISH THIS
        //
        let isThereSmthToShow = self.coronaStore.confirmedHistory.series(for: item.countryRegion).max() ?? 0 > 0
        
        if isThereSmthToShow {
            self.coronaStore.selectedCountry = item.countryRegion
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
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
