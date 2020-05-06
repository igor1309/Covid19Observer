//
//  CoronaStore.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//
//  Inspired by
//  https://heartbeat.fritz.ai/coronavirus-visualisation-on-maps-with-swiftui-and-combine-on-ios-c3f6e04c2634
//  https://github.com/anupamchugh/iowncode/tree/master/SwiftUICoronaMapTracker/SwiftUICoronaMapTracker
//

import SwiftUI
import Combine
import SwiftPI

extension TestingCorona { //CoronaStore {
    
    /// Based on https://bestkora.com/IosDeveloper/modern-networking-in-swift-5-with-urlsession-combine-and-codable/
    ///
    func load<T: Decodable>(_ nameJSON: String, type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        //--------------------------------------------------------
        //  MARK: НУЖНО ПЕРЕПИСАТЬ!!! - Важны ошибки (или нет??)
        //
        
        Just(nameJSON)
            .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let file = dir.appendingPathComponent(nameJSON)
                let data = try! Data(contentsOf: file)
                return Just(data)
                    .eraseToAnyPublisher()
        }
        .decode(type: T.self, decoder: decoder)
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    
    func fetch(caseType: CaseType, endpoint: JHEndPoint) -> AnyPublisher<Corona, FetchError> {
        
        Future<Corona, FetchError> { [unowned self] promise in
            URLSession.shared.dataTaskPublisher(for: endpoint.url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                        200...299 ~= httpResponse.statusCode else {
                            throw FetchError.responseError(
                                ((response as? HTTPURLResponse)?.statusCode ?? 500,
                                 String(data: data, encoding: .utf8) ?? ""))
                    }
                    return data
            }
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .tryMap { (response) -> Corona in
                if response.features.isNotEmpty {
                    var corona = Corona(caseType, endPoint: endpoint)
                    corona.update(with: response, completion: { })
                    return corona
                } else {
                    throw FetchError.emptyResponse
                }
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { (completion) in
                    //--------------------------------------------------------
                    //  MARK: FINISH HANDLING ALL ERRORS, MARKERS AND FLAGS!!!
                    //
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as FetchError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.genericError))
                        }
                    } else {
                        //------------------------
                        //  MARK: success is here - write flag!
                    }
            },
                receiveValue: { corona in
                    promise(.success(corona))
            })
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}


extension CoronaStore {
    
    func load(endpoint: JHEndPoint) -> AnyPublisher<Corona, FetchError> {
        Future<Corona, FetchError> { [unowned self] promise in
            
            FileManager.default.load(endpoint.filename, type: Corona.self)
                //  MARK: CATCH AND PROCESS ERRORS!!!
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { (completion) in
                        if case let .failure(error) = completion {
                            switch error {
                            case let urlError as URLError:
                                promise(.failure(.urlError(urlError)))
                            case let decodingError as DecodingError:
                                promise(.failure(.decodingError(decodingError)))
                            case let apiError as FetchError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(.genericError))
                            }
                        }
                },
                    receiveValue: {
//                        promise(.success($0))
                        switch endpoint {
                        case .currentByRegion:
                            self.coronaByRegion = $0
                        case .currentByCountry:
                            self.coronaByCountry = $0
                        default: break
                        }
                })
                .store(in: &self.storage)
        }
        .eraseToAnyPublisher()
    }
}



final class CoronaStore: ObservableObject {
    
    @Published var caseType = CaseType.byCountry {
        didSet { countOutbreak() }
    }
    
    @Published var coronaByCountry = Corona(.byCountry, endPoint: .currentByCountry/*, saveTo: "coronaByCountry.json"*/)
    @Published var coronaByRegion = Corona(.byRegion, endPoint: .currentByRegion/*, saveTo: "coronaByRegion.json"*/)
    
    @Published private(set) var confirmedHistory = History(
        saveTo: "confirmedHistory.json",
        kind: .confirmed,
        deviationThreshold: 100)
    @Published private(set) var deathsHistory = History(
        saveTo: "deathsHistory.json",
        kind: .deaths,
        deviationThreshold: 10)
    
    @Published private(set) var outbreak = Outbreak()
    
    @Published var selectedCountry: String = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Russia" {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }
    
    @Published var mapOptions: MapOptions {
        didSet {
            if let encoded = try? JSONEncoder().encode(mapOptions) {
                UserDefaults.standard.set(encoded, forKey: "mapOptions")
            }
            
            countOutbreak()
        }
    }
    
    private var storage = [AnyCancellable]()
    
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.combinedKey < $1.combinedKey })
    
    let countriesWithIso2: [String: String]
    
    init() {
        countriesWithIso2 = population
            .filter { $0.uid < 1_000 }
            .reduce(into: [String: String]()) { $0[$1.combinedKey] = $1.iso2 }
        
        
        /// Map Options
        //        /// https://www.hackingwithswift.com/example-code/system/how-to-load-and-save-a-struct-in-userdefaults-using-codable
        //        if let savedOptions = UserDefaults.standard.object(forKey: "mapOptions") as? Data {
        //            if let loadedOptions = try? JSONDecoder().decode(MapOptions.self, from: savedOptions) {
        //                mapOptions = loadedOptions
        //            } else {
        //                mapOptions = MapOptions()
        //            }
        //        } else {
        //            mapOptions = MapOptions()
        //        }
        mapOptions = UserDefaults.standard.getObj(forKey: "mapOptions", /*castTo: MapOptions.self,*/ empty: MapOptions())
        
        
        //  MARK: как сделать publisher<Bool, Never> ? и объединить их: countOutbreak() и countNewAndCurrent() нужно считать после загрузки текущих данных (две Corona) и исторических (две History) — это 4(3) ассинхронных действия. Без объединения countOutbreak() и countNewAndCurrent() вызываются 4(3) раза!!
        populateCorona {
            //            self.countOutbreak()
        }
        populateHistory {
            //            self.countOutbreak()
        }
        
        
        //  MARK: - FIX THIS что-то тут не то
        ///  updateEmptyOrOldStore должен содержать  какую-то `closure` ??
        DispatchQueue.main.async {
            /// update if data is empty or old
            self.updateEmptyOrOldStore()
        }
        
        
        
        
        let byCountryPub = $coronaByCountry
            .map { $0.isUpdateCompleted ?? false }
            .filter { $0 }
        
        let byRegionPub = $coronaByRegion
            .map { $0.isUpdateCompleted ?? false }
            .filter {
                print("PUBLISHER coronaByCountry emitted: \($0)")
                return $0 }
        //
        //        let confirmedPub = $confirmedHistory
        //            .map { $0.isUpdateCompleted ?? false}
        //            .filter { $0 }
        //
        //        let deathPub = $deathsHistory
        //            .map { $0.isUpdateCompleted ?? false}
        //            .filter { $0 }
        
        //        let corona = Publishers.Zip(byRegionPub, byCountryPub)
        //        let history = Publishers.Zip(confirmedPub, deathPub)
        //        let store = Publishers.Zip(corona, history)
        
        //                let corona =
        //        Publishers.Merge4(byCountryPub, byRegionPub, confirmedPub, deathPub)
        byRegionPub
            //            .reduce(true, { $0 && $1 })
            //            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print(">> published, running countOutbreak() ")
                self.countOutbreak()
        }
        .store(in: &storage)
    }
}

extension CoronaStore {
    var isCasesUpdateCompleted: Bool {
        coronaByCountry.isUpdateCompleted ?? false && coronaByRegion.isUpdateCompleted ?? false
    }
    
    var isHistoryUpdateCompleted: Bool {
        confirmedHistory.isUpdateCompleted ?? false && deathsHistory.isUpdateCompleted ?? false
    }
    
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
    
    var selectedCountryOutbreak: Outbreak {
        guard let countryCase = coronaByCountry.cases.first(where: { $0.name == selectedCountry }) else { return Outbreak() }
        
        let population = populationOf(country: selectedCountry)
        
        return Outbreak(population: population,
                        confirmed: countryCase.confirmed,
                        confirmedNew: countryCase.confirmedNew,
                        confirmedCurrent: countryCase.confirmedCurrent,
                        recovered: countryCase.recovered,
                        deaths: countryCase.deaths,
                        deathsNew: countryCase.deathsNew,
                        deathsCurrent: countryCase.deathsCurrent)
    }
    
    var countryRegions: [String] { coronaByCountry.cases.map { $0.name }.sorted() }
    
    var timeSinceCasesUpdateStr: String { coronaByCountry.lastSyncDate.hoursMunutesTillNow }
    
    var allCountriesCFR: [Int] {
        let confirmed = confirmedHistory.allCountriesTotals
        let deaths = deathsHistory.allCountriesTotals
        
        var allCFR = [Int]()
        for i in 00..<confirmed.count {
            //  MARK: FINISH THIS
            //  ГРАФИКЕ СТРОЯТСЯ ПО [Int] нужно переходить к CGFloat
            let cfr = confirmed[i] == 0 ? 0 : 100 * 100 * deaths[i] / confirmed[i]
            allCFR.append(cfr)
        }
        return allCFR
    }
}

extension CoronaStore {
    
    func updateEmptyOrOldStore() {
        if coronaByCountry.cases.isEmpty || coronaByCountry.isDataOld {
            print("CoronaStore: Cases Data empty or old, need to fetch")
            populateCorona() {
                self.countNewAndCurrent()
            }
        }
        
        if confirmedHistory.countryRows.isEmpty || confirmedHistory.isDataOld || deathsHistory.countryRows.isEmpty || deathsHistory.isDataOld {
            print("CoronaStore: History Data empty or old, need to fetch")
            populateHistory() {
                self.countNewAndCurrent()
            }
        }
    }
    
    func updateCorona(completion: @escaping () -> Void) {
        populateCorona() {
            self.countOutbreak()
            completion()
        }
    }
    
    private func populateCorona(completion: @escaping () -> Void) {
        
        coronaByCountry.isUpdateCompleted = false
        coronaByRegion.isUpdateCompleted = false
        
        //  MARK: как сделать publisher<Bool, Never> ? и объединить их: countOutbreak() и countNewAndCurrent() нужно считать после загрузки текущих данных (две Corona) и исторических (две History) — это 4(3) ассинхронных действия. Без объединения countOutbreak() и countNewAndCurrent() вызываются 4(3) раза!!
        
        /// by `Country`
        let countryPub = coronaByCountry.fetch()
        
        countryPub
            .sink { response in
                self.coronaByCountry.update(with: response, completion: completion)
        }
        .store(in: &storage)
        
        /// by `Region`
        coronaByRegion
            .fetch()
            .sink { response in
                self.coronaByRegion.update(with: response, completion: completion)
        }
        .store(in: &storage)
    }
    
    func series(for dataKind: DataKind, appendCurrent: Bool, forAllCountries: Bool = false) -> [Int] {
        
        if forAllCountries {
            switch dataKind {
            case .confirmedTotal:
                return confirmedHistory.allCountriesTotals
            case .confirmedDaily:
                return confirmedHistory.allCountriesDailyChange
            case .deathsTotal:
                return deathsHistory.allCountriesTotals
            case .deathsDaily:
                return deathsHistory.allCountriesDailyChange
            case .cfr:
                return allCountriesCFR
            }
        } else {
            var series: [Int]
            
            switch dataKind {
            case .confirmedTotal:
                series = confirmedHistory.series(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.confirmed
                    series.append(last)
                }
            case .confirmedDaily:
                series = confirmedHistory.dailyChange(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.confirmedCurrent
                    series.append(last)
                }
            case .deathsTotal:
                series = deathsHistory.series(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.deaths
                    series.append(last)
                }
            case .deathsDaily:
                series = deathsHistory.dailyChange(for: selectedCountry)
                if appendCurrent {
                    let last = selectedCountryOutbreak.deathsCurrent
                    series.append(last)
                }
            case .cfr:
                //  MARK: FIX THIS
                //
                return allCountriesCFR
            }
            
            //  MARK: negative values crash charts
            //
            return series.filter { $0 >= 0 }
        }
    }
    
    
    /// ex `processCases()`
    private func countOutbreak() {
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in coronaByCountry.cases {
            totalCases += cases.confirmed
            totalDeaths += cases.deaths
            totalRecovered += cases.recovered
        }
        
        //  MARK: count new and current cases is called separately in countNewAndCurrent()
        outbreak.population = populationOf(country: nil)
        outbreak.confirmed = totalCases
        outbreak.recovered = totalRecovered
        outbreak.deaths = totalDeaths
        
        countNewAndCurrent()
    }
    
    private func countNewAndCurrent() {
        var totalConfirmedNew = 0
        var totalConfirmedCurrent = 0
        
        var totalDeathsNew = 0
        var totalDeathsCurrent = 0
        
        for index in coronaByCountry.cases.indices {
            
            let name = coronaByCountry.cases[index].name
            
            //  Confirmed Cases
            
            let confirmedLast = confirmedHistory.last(for: name)
            let confirmedPrevious = confirmedHistory.previous(for: name)
            
            let confirmedNew = confirmedLast - confirmedPrevious
            coronaByCountry.cases[index].confirmedNew = confirmedNew
            
            let comfirmedCurrent = coronaByCountry.cases[index].confirmed - confirmedLast
            coronaByCountry.cases[index].confirmedCurrent = comfirmedCurrent
            
            totalConfirmedNew += confirmedNew
            totalConfirmedCurrent += comfirmedCurrent
            
            
            //  Deaths
            
            let deathsLast = deathsHistory.last(for: name)
            let deathsPrevious = deathsHistory.previous(for: name)
            
            let deathsNew = deathsLast - deathsPrevious
            coronaByCountry.cases[index].deathsNew = deathsNew
            
            let deathsCurrent = coronaByCountry.cases[index].deaths - deathsLast
            coronaByCountry.cases[index].deathsCurrent = deathsCurrent
            
            totalDeathsNew += deathsNew
            totalDeathsCurrent += deathsCurrent
            
        }
        
        
        /// other properties of outbreak set in processCases()
        outbreak.confirmedNew = totalConfirmedNew
        outbreak.confirmedCurrent = totalConfirmedCurrent
        
        outbreak.deathsNew = totalDeathsNew
        outbreak.deathsCurrent = totalDeathsCurrent
        
        
    }
}

extension CoronaStore {
    func updateHistory(completion: @escaping () -> Void) {
        populateHistory() {
            self.countOutbreak()
            completion()
        }
    }
    
    private func populateHistory(completion: @escaping () -> Void) {
        
        confirmedHistory.isUpdateCompleted = false
        deathsHistory.isUpdateCompleted = false
        
        //  MARK: как сделать publisher<Bool, Never> ? и объединить их: countOutbreak() и countNewAndCurrent() нужно считать после загрузки текущих данных (две Corona) и исторических (две History) — это 4(3) ассинхронных действия. Без объединения countOutbreak() и countNewAndCurrent() вызываются 4(3) раза!!
        
        /// `confirmed`
        let confirmedPub = confirmedHistory.fetch()
        
        confirmedPub
            .sink { history in
                self.confirmedHistory.update(from: history, completion: completion)
        }
        .store(in: &storage)
        
        /// `deaths`
        let deathsPub = deathsHistory.fetch()
        
        deathsPub
            .sink { history in
                self.deathsHistory.update(from: history, completion: completion)
        }
        .store(in: &storage)
    }
}

extension CoronaStore {
    
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
