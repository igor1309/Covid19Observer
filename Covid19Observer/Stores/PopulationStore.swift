//
//  PopulationStore.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 08.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine

final class PopulationStore: ObservableObject {
    
    enum FilterKind: String, CaseIterable, Hashable {
        case countries = "Countries"
        case us = "US+"
        case canada = "Canada+"
        case china = "China+"
        
        var id: String { rawValue }
    }
    
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    
    @Published var query: String = ""
    @Published var selectedFilter = FilterKind.countries
    @Published var queryResult: Population = []
    
    init() {
        //  create query subscription
        Publishers.CombineLatest(
            $query
                .removeDuplicates(),
            $selectedFilter
        )
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .map { query, filter in
                self.queryList(query: query, filter: filter)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.queryResult = $0
        }
        .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}

extension PopulationStore {
    
    private func queryList(query: String, filter: FilterKind) -> Population {
        
        func isIncluded(_ item: PopulationElement, query: String, filter: FilterKind) -> Bool {
            
            guard query.count > 1 else {
                return false
            }
            
            let containsQuery: Bool
            let hasIdOrIso: Bool
            let lowercasedQuery = query.lowercased()
            
            switch filter {
            case .countries:
                containsQuery = item.countryRegion.lowercased().contains(lowercasedQuery)
                hasIdOrIso = item.uid < 1000
            case .us:
                containsQuery = item.provinceState.lowercased().contains(lowercasedQuery)
                hasIdOrIso = item.iso3 == "USA" && item.uid <= 84000056
            case .canada:
                containsQuery = item.provinceState.lowercased().contains(lowercasedQuery)
                hasIdOrIso = item.iso3 == "CAN"
            case .china:
                containsQuery = item.provinceState.lowercased().contains(lowercasedQuery)
                hasIdOrIso = item.iso3 == "CHN"
            }
            
            return containsQuery && hasIdOrIso
        }
        
        return population.filter { isIncluded($0, query: query, filter: filter) }
    }
    
    /// Return population for the country and for the world if country is nil. `Regions and territories are not yet supported`.
    /// - Parameter country: country name
    /// - Returns: population for the country and for the world if country is nil
    func populationOf(country: String?) -> Int {
        guard let country = country else {
            return population
                .filter { $0.uid < 1000 }
                .reduce(0, { $0 + $1.population! })
        }
        
        guard let pop = population
            .first(where: {
                $0.combinedKey == country && $0.uid < 1000
            }) else { return 0 }
        
        return pop.population ?? 0
    }
}
