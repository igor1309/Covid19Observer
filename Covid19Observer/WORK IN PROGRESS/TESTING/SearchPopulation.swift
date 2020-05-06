//
//  SearchPopulation.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 22.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine


//  MARK: TESTING PUBLISHERS

/// альтернативный подход:
/// assign retains the self which creates a memory leak if you assign to self and store cancellable inside a self. Sink allows you to make weak self.
/// https://twitter.com/mecid/status/1252920639826124801?ref_src=twsrc%5Etfw
final class SearchPopulation: ObservableObject {
    @Published var query: String = ""
    
    @Published private var selectedFilter = FilterKind.countries
    
    private enum FilterKind: String, CaseIterable, Hashable {
        case countries = "Countries"
        case us = "US+"
        case canada = "Canada+"
        case china = "China+"
        
        var id: String { rawValue }
    }
    
    @Published var population = [PopulationElement]()
    
    private var validSearchText: AnyPublisher<String, Never> {
        $query
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    let populationDB = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    
    private var storage = [AnyCancellable]()
    
    init() {
        Publishers.CombineLatest(validSearchText, $selectedFilter)
            .flatMap {
                (search, kind) -> AnyPublisher<[PopulationElement], Never> in
                let pop = self.populationDB.filter { self.filterFunc($0) }
                return Just(pop).eraseToAnyPublisher()
        }
        .assign(to: \.population, on: self)
        .store(in: &storage)
    }
    
    private func filterFunc(_ item: PopulationElement) -> Bool {
        let searchCondition = query.count > 2
            ? item.countryRegion.contains(query)
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
}
