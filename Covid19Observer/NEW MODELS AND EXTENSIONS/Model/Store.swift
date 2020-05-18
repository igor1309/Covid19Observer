//
//  Store.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

extension Store {
    //  MARK: - TESTING
    func testing() {
        print("testing")
        confirmedHistory.test()
        deathsHistory.test()
    }
    func resetOutbreak() {
        self.outbreak = Outbreak()
    }
}

extension Date {
    func isDataOld(threshold: DateComponents) -> Bool {
        let calendar = Calendar.autoupdatingCurrent
        let thresholdDate = calendar.date(byAdding: threshold, to: Date())!
        let compare = calendar.compare(thresholdDate, to: self, toGranularity: .minute)
        return compare == .orderedDescending
    }
}

enum SyncStatus: String {
    case loadFailure = "⚠️ load failed"
    case fetchFailure = "⚠️ fetch failed"
    case loading, loaded, fetching, fetched
    
    private var isNotUpdating: Bool {
        switch self {
        case .fetchFailure, .loadFailure, .loaded, .fetched:
            return true
        case .loading, .fetching:
            return false
        }
    }
    
    var isUpdating: Bool {
        switch self {
        case .fetchFailure, .loadFailure, .loaded, .fetched:
            return false
        case .loading, .fetching:
            return true
        }
    }
    
    func syncText(kind: String, for syncDate: Date, threshold: DateComponents) -> String {
        
        guard self.isNotUpdating else {
            return "…"
        }
        
        if syncDate == .distantPast {
            return "\(kind) data is missing"
        } else if syncDate.hoursMunutesTillNow == "0min" {
            return "\(kind) updated just now."
        } else if syncDate.isDataOld(threshold: threshold) {
            return "\(kind) is old (more than \(syncDate.hoursMunutesTillNowNice))."
        } else {
            return "Last update for \(kind) \(syncDate.hoursMunutesTillNowNice)."
        }
    }
    
    func syncColor(for syncDate: Date, threshold: DateComponents) -> Color {
        
        guard self.isNotUpdating else {
            return .secondary
        }
        
        if syncDate.hoursMunutesTillNow == "0min" {
            return .systemGreen
        } else if syncDate.isDataOld(threshold: threshold) {
            return .systemRed
        } else {
            return .secondary
        }
    }
}



final class Store: ObservableObject {
    
    @Published var caseType = CaseType.byCountry
    
    //  MARK: - API
    
    let coronaAPI: CoronaAPI//JohnHopkinsAPI
    
    //  MARK: - Constants
    
    let currentThreshold = DateComponents(hour: -1)
    let historyThreshold = DateComponents(hour: -6)
    let confirmedDeviationThreshold: CGFloat = 100
    let deathsDeviationThreshold: CGFloat = 10
    
    //  MARK: - Current
    
    @Published private(set) var currentByCountry = Current(type: .byCountry, syncDate: .distantPast) {
        didSet { save(current: currentByCountry) }
    }
    @Published private(set) var currentByRegion = Current(type: .byRegion, syncDate: .distantPast) {
        didSet { save(current: currentByRegion) }
    }
    
    //  MARK: - History
    
    @Published private(set) var confirmedHistory = Historical(type: .confirmed, syncDate: .distantPast) {
        didSet { save(history: confirmedHistory) }
    }
    @Published private(set) var deathsHistory = Historical(type: .deaths, syncDate: .distantPast) {
        didSet { save(history: deathsHistory) }
    }
    
    //  MARK: - Extra
    
    @Published private(set) var extra = Extra(newAndCurrents: [])
    //  MARK: - Outbreak
    
    @Published private(set) var outbreak = Outbreak()
    
    var selectedCountryOutbreak: Outbreak {
        guard let countryCase = currentByCountry.cases.first(where: { $0.name == selectedCountry }) else { return Outbreak() }
        guard let newAndCurrent = extra.newAndCurrents.first(where: { $0.name == selectedCountry }) else { return Outbreak() }
        
        let population = populationOf(country: selectedCountry)
        
        return Outbreak(population: population,
                        confirmed: countryCase.confirmed,
                        confirmedNew: newAndCurrent.confirmedNew,
                        confirmedCurrent: newAndCurrent.confirmedCurrent,
                        recovered: countryCase.recovered,
                        deaths: countryCase.deaths,
                        deathsNew: newAndCurrent.deathsNew,
                        deathsCurrent: newAndCurrent.deathsCurrent)
    }
    
    //  MARK: - Variations
    
    @Published var confirmedVariation = Variation(type: .confirmed, deviations: [])
    @Published var deathsVariation = Variation(type: .deaths, deviations: [])
    
    @Published var selectedCountry: String = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Russia" {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }
    
    //  MARK: - Fetch Triggers, Status and Flags
    
    private let currentUpdateRequested = PassthroughSubject<String, Never>()
    private let historyUpdateRequested = PassthroughSubject<String, Never>()
    
    enum Corona: Hashable {
        case current(CurrentType)
        case history(HistoryType)
    }
    @Published var syncStatus = [Corona: SyncStatus]()

    @Published private(set) var currentIsUpdating = false
    @Published private(set) var historyIsUpdating = false
    
    //  MARK: - Population
    
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    let countriesWithIso2: [String: String]
    
    //  MARK: - init
    
    init(api: CoronaAPI = JohnHopkinsAPI.shared) {
        self.coronaAPI = api
        
        self.countriesWithIso2 = population
            .filter { $0.uid < 1_000 }
            .reduce(into: [String: String]()) {
                $0[$1.combinedKey] = $1.iso2
        }
        
        self.syncStatus[.current(.byCountry)] = .loading
        self.syncStatus[.current(.byRegion)] = .loading
        self.syncStatus[.history(.confirmed)] = .loading
        self.syncStatus[.history(.deaths)] = .loading
        
        createSubscriptions()
    }
    
    //  MARK: - Subscription Storage
    
    private var cancellables = Set<AnyCancellable>()
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}

extension Store {
    
    //  MARK: - Fetch
    func fetchCurrent() {
        currentIsUpdating = true
        syncStatus[.current(.byCountry)] = .fetching
        syncStatus[.current(.byRegion)] = .fetching
        currentUpdateRequested.send("update")
    }
    func fetchHistory() {
        historyIsUpdating = true
        syncStatus[.history(.confirmed)] = .fetching
        syncStatus[.history(.deaths)] = .fetching
        historyUpdateRequested.send("update")
    }
    
    //  MARK: - Create Subscriptions
    private func createSubscriptions() {
        
        //  MARK: Load Subscriptions
        
        //  History
        /// Load saved history or empty if nothins is saved
        for history in [confirmedHistory, deathsHistory] {
            FileManager.default.loadJSON(type: Historical.self, from: "\(history.type.filename)")
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        print(error)
                        self?.syncStatus[.history(history.type)] = .loadFailure
                    case .finished:
                        print("JSON loaded from \(history.type.filename) OK")
                        self?.syncStatus[.history(history.type)] = .loaded
                    }
                }, receiveValue:  {
                    [weak self] in
                    switch history.type {
                    case .confirmed:
                        self?.confirmedHistory = $0
                    case .deaths:
                        self?.deathsHistory = $0
                    }
                    self?.syncStatus[.history(history.type)] = .loaded
                })
                .store(in: &cancellables)
        }
        
        //  Current
        /// Load saved Current or empty if nothing is saved
        for current in [currentByCountry, currentByRegion] {
            FileManager.default.loadJSON(type: Current.self, from: "\(current.type.filename)")
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        print(error)
                        self?.syncStatus[.current(current.type)] = .loadFailure
                    case .finished:
                        print("JSON loaded from \(current.type.filename) OK")
                        self?.syncStatus[.current(current.type)] = .loaded
                    }
                }, receiveValue:  {
                    [weak self] in
                    switch current.type {
                    case .byCountry:
                        self?.currentByCountry = $0
                    case .byRegion:
                        self?.currentByRegion = $0
                    }
                    self?.syncStatus[.current(current.type)] = .loaded
                })
                .store(in: &cancellables)
        }
        
        
        //  MARK: Fetch Subscriptions
        
        //  History
        /// get remote csv and parse it, update if not nil
        for history in [confirmedHistory, deathsHistory] {
            historyUpdateRequested
                .setFailureType(to: Error.self)
                .flatMap { _ in
                    self.coronaAPI.fetchHistorical(type: history.type)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    print("\(history.type.rawValue) history fetching error: \(error)")
                case .finished:
                    print("updating \(history.type.rawValue) history OK")
                }
                self?.syncStatus[.history(history.type)] = .fetchFailure
                }, receiveValue: {
                    [weak self] in
                    switch history.type {
                    case .confirmed:
                        self?.confirmedHistory = $0
                    case .deaths:
                        self?.deathsHistory = $0
                    }
                    self?.syncStatus[.history(history.type)] = .fetched
            })
                .store(in: &cancellables)
        }
        
        //  Current
        for current in [currentByCountry, currentByRegion] {
            currentUpdateRequested
                .setFailureType(to: Error.self)
                .flatMap { _ in
                    self.coronaAPI.fetchCurrent(type: current.type)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    print("current \(current.type.rawValue) fetching error: \(error)")
                case .finished:
                    print("updating current of \(current.type.rawValue) OK")
                }
                self?.syncStatus[.current(current.type)] = .fetchFailure
                }, receiveValue: {
                    [weak self] in
                    switch current.type {
                    case .byCountry:
                        self?.currentByCountry = $0
                    case .byRegion:
                        self?.currentByRegion = $0
                    }
                    self?.syncStatus[.current(current.type)] = .fetched
                    self?.currentIsUpdating = false
            })
                .store(in: &cancellables)
        }
        
        
        //  MARK: Deviations Subscriptions
        
        //  confirmed
        $confirmedHistory
            .filter { $0.countryRows.isNotEmpty }
            .removeDuplicates()
            .map { Convertor.deviations(from: $0.countryRows, type: .confirmed, threshold: self.confirmedDeviationThreshold) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] deviation in
                self?.confirmedVariation = deviation
        }
        .store(in: &cancellables)
        
        //  deaths
        $deathsHistory
            .filter { $0.countryRows.isNotEmpty }
            .removeDuplicates()
            .map { Convertor.deviations(from: $0.countryRows, type: .deaths, threshold: self.deathsDeviationThreshold) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] deviation in
                self?.deathsVariation = deviation
        }
        .store(in: &cancellables)
        
        
        //  MARK: Extra Subscription
        /// Count Extra (New and Current)
        Publishers.CombineLatest3(
            $currentByCountry,
            $confirmedHistory,
            $deathsHistory
        )
            .filter { (current, confirmed, deaths) -> Bool in
                current.cases.isNotEmpty
                    && confirmed.countryRows.isNotEmpty
                    && deaths.countryRows.isNotEmpty
        }
        .map { (byCountry, confirmed, deaths) in
            Extra(coronaByCountry: byCountry, confirmedHistory: confirmed, deathsHistory: deaths)}
            .removeDuplicates()
            .sink { [weak self] in
                self?.extra = $0
                print("calculated Extra")
        }
        .store(in: &cancellables)
        
        
        //  MARK: Outbreak Subscription
        /// Update Outbreak when properties change
        $extra
            .filter { $0.newAndCurrents.isNotEmpty }
            .removeDuplicates()
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .flatMap { _ in
                Just(Outbreak(population: self.populationOf(country: nil),
                              currentByCountry: self.currentByCountry,
                              confirmedHistory: self.confirmedHistory,
                              deathsHistory: self.deathsHistory))
        }
        .replaceError(with: Outbreak())
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink {
            [weak self] in
            self?.outbreak = $0
            print("Outbreak Subscription OK \($0)")
        }
        .store(in: &cancellables)
        
        //  MARK: Updating Flag Subscription
        $outbreak
            .zip($confirmedHistory, $deathsHistory)
            //            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.currentIsUpdating = false
                self?.historyIsUpdating = false
        }
        .store(in: &cancellables)
        
        //  MARK: Status isUpdating
        //  History
        $syncStatus
            .compactMap { $0[.history(.confirmed)] }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.historyIsUpdating = $0.isUpdating
        }
        .store(in: &cancellables)
        
        //  Current
        $syncStatus
            .compactMap { $0[.current(.byCountry)] }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.currentIsUpdating = $0.isUpdating
        }
        .store(in: &cancellables)
    }
}



extension Store {
    //  MARK: - Save
    private func save(history: Historical) {
        FileManager.default.saveJSON(data: history, to: "\(history.type.filename)")
    }
    private func save(current: Current) {
        FileManager.default.saveJSON(data: current, to: "\(current.type.filename)")
    }
}

extension Store {
    
    func total(for caseDataType: CaseDataType) -> String {
        switch caseDataType {
        case .confirmed:
            return outbreak.confirmedStr
        case .new:
            return outbreak.confirmedNewStr
        case .current:
            return outbreak.confirmedCurrentStr
        case .deaths:
            return outbreak.deathsStr
        case .cfr:
            return outbreak.cfrStr
        }
    }
}

extension Store {
    var selectedCountryPopulation: Int {
        /// страна если uid < 1000
        if let pop = population
            .first(where: { $0.countryRegion == selectedCountry && $0.uid < 1000 })?
            .population {
            return pop
        } else {
            return 1
        }
    }
    
    /// Return population for the country and for the world if country is nil. `Regions and territories are not yet supported`.
    /// - Parameter country: country name or nil for the world
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
    //  -------------------------------------------------------------
}

//  MARK: - Sync View Model Helpers
extension Store {
    
    //  MARK: Uppdate if Old (or loaded with failure)
    
    func updateStoreIfDataIsOld() {
        //  data needs some time to load first!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.currentByCountry.syncDate.isDataOld(threshold: self.currentThreshold) {
                self.fetchCurrent()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.confirmedHistory.syncDate.isDataOld(threshold: self.historyThreshold) {
                self.fetchHistory()
            }
        }
    }
    
    //  MARK: Status and Sync Info
    
    //  status should be always set (starting in init),
    //  if it's nil than it's a program error
    //  so it's safe to force unwrap
    
    var currentSyncInfo: (status: String, text: String, color: Color) {
        let kind = "Current"
        let status = syncStatus[.current(.byCountry)]!
        let date = currentByCountry.syncDate
        let threshold = currentThreshold
        
        return (
            status: status.rawValue,
            text: status.syncText(kind: kind, for: date, threshold: threshold),
            color: status.syncColor(for: date, threshold: threshold)
        )
    }
    
    var historySyncInfo: (status: String, text: String, color: Color) {
        let kind = "History"
        let status = syncStatus[.history(.confirmed)]!
        let date = confirmedHistory.syncDate
        let threshold = historyThreshold
        
        return (
            status: status.rawValue,
            text: status.syncText(kind: kind, for: date, threshold: threshold),
            color: status.syncColor(for: date, threshold: threshold)
        )
    }
}

//  MARK: Case Annotation (for map)
extension Store {
    func caseAnnotations(filterValue: Int) -> [CaseAnnotation] {
        let annotations: [CaseAnnotation]
        
        switch caseType {
        case .byCountry:
            annotations = currentByCountry.caseAnnotations
        case .byRegion:
            annotations = currentByRegion.caseAnnotations
        }
        
        return annotations.filter { $0.value > filterValue }
    }
}

//  MARK: Other View Model Helpers
extension Store {
    func maximumForCasesChart(type: CaseDataType) -> CGFloat {
        let maximum: CGFloat
        
        switch type {
        case .confirmed:
            maximum = CGFloat(currentByCountry.cases.map { $0.confirmed }.max() ?? 1)
        case .new:
            maximum = CGFloat(extra.newAndCurrents.map { $0.confirmedNew }.max() ?? 1)
        case .current:
            maximum = CGFloat(extra.newAndCurrents.map { $0.confirmedCurrent }.max() ?? 1)
        case .deaths:
            maximum = CGFloat(currentByCountry.cases.map { $0.deaths }.max() ?? 1)
        case .cfr:
            //            maximum = 0.15
            maximum = CGFloat(currentByCountry.cases
                //  MARK: - FINISH THIS
                //  move to model
                //
                /// countries with small number of cases can have a huge CFR (Case Fatality Rate) and distort scale
                //                .filter { $0.confirmed > 50 }
                .map { $0.cfr }.max() ?? 0.15)//0.15
        }
        
        return maximum
    }
}
