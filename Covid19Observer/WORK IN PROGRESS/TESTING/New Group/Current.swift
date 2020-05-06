//
//  Current.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 24.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import Combine
import SwiftPI

struct Current {
    let type: CurrentType
    
    private(set) var cases = [CaseData]()
    private(set) var caseAnnotations = [CaseAnnotation]()
    
    private(set) var lastFetchDate = Date.distantPast
    private(set) var isFetchOK: Bool?
    var fetchError: FetchError?
}

extension Current {
    init(type: CurrentType, response: CoronaResponse) {
        var current = Current(type: type)
        #warning("completion here?")
        current.update(with: response) {}
        self = current
    }
}

extension Current {
    var isEmpty: Bool { cases.isEmpty }
    var isNotEmpty: Bool { !isEmpty }
    var isOld: Bool { lastFetchDate.distance(to: Date()) > 1 * 60 * 60 }
    
    var endpoint: Endpoint { .current(type) }
    
    var name: String { type.rawValue }
}

extension Current: Codable {
    private enum CodingKeys: CodingKey {
        case type, cases, caseAnnotations, lastFetchDate, isFetchOK
    }
}

extension Current {
    
    #warning("do you need completion here ?")
    mutating func update(with response: CoronaResponse, completion: @escaping () -> Void) {
        
        //  MARK: FINISH THIS
        //
        
        guard response.features.isNotEmpty else {
            print("response is empty, nothing to process")
            self.fetchError = FetchError.emptyResponse
            self.isFetchOK = false
            return
        }
        
        /// `process`
        processCases(response: response)
        
        /// marks
        //  MARK: FIX THIS
        //  сделать переменную-буфер ошибок и выводить её в Settings или как-то еще
        self.lastFetchDate = Date()
        self.isFetchOK = true
        self.fetchError = nil
        
        print("update: current \(name) updated with response provided")
        
        
        DispatchQueue.main.async {
            completion()
        }
    }
    
    private mutating func processCases(response: CoronaResponse) {
        var caseAnnotations: [CaseAnnotation] = []
        var caseData: [CaseData] = []
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in response.features {
            
            let recovered = cases.attributes.recovered ?? 0
            let confirmed = cases.attributes.confirmed ?? 0
            let deaths = cases.attributes.deaths ?? 0
            let cfr = confirmed == 0 ? 0 : Double(deaths) / Double(confirmed)
            let title = cases.attributes.provinceState ?? cases.attributes.countryRegion ?? ""
            
            caseAnnotations.append(
                CaseAnnotation(
                    title: title,
                    confirmed: "Confirmed \(confirmed.formattedGrouped)",
                    deaths: "\(deaths.formattedGrouped) deaths",
                    cfr: "CFR \(cfr.formattedPercentageWithDecimals)",
                    value: confirmed,
                    coordinate: .init(latitude: cases.attributes.latitude ?? 0.0,
                                      longitude: cases.attributes.longitude ?? 0.0)))
            
            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
            
            #warning("count new and current cases is called separately in countNewAndCurrent()")
            caseData.append(
                CaseData(
                    name: title,
                    confirmed: confirmed,
                    //  MARK: count new and current cases is called separately in countNewAndCurrent()
                    confirmedNew: 0,
                    confirmedCurrent: 0,
                    recovered: recovered,
                    deaths: deaths,
                    //  MARK: count new and current cases is called separately in countNewAndCurrent()
                    deathsNew: 0,
                    deathsCurrent: 0//,
            ))
        }
        
        
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        //        self.caseAnnotations = caseAnnotations.filter { $0.value > (mapOptions.isFiltered ? mapOptions.lowerLimit : 0) }
        self.caseAnnotations = caseAnnotations
        
        //  MARK: НЕПРАВИЛЬНО ФИЛЬТРОВАТЬ ЗДЕСЬ ?????
        //        self.currentCases = caseData.filter { $0.confirmed > (mapOptions.isFiltered ? mapOptions.lowerLimit : 0) }
        self.cases = caseData
        
        // ЭТО В CORONASTORE!
        // countNewAndCurrent()
    }
}

extension Current {
    func save(to filename: String) {
        #warning("правильно ли выбрано DispatchQueue.global().async??")
        DispatchQueue.global().async {
            /// save to local file if data is not empty
            if self.cases.isNotEmpty {
                print("saving current data to \(filename)")
                saveJSONToDocDir(data: self, filename: filename)
            } else {
                //  MARK: FIX THIS
                //  сделать переменную-буфер ошибок и выводить её в Settings или как-то еще
                print("case data is empty, nothing to save")
            }
        }
    }
    
    static private func empty(type: CurrentType) -> Current {
        Current(type: type)
    }
    
    /// load  from disk if there is saved data and data in not empty, otherwise return empty current
    static func load(type: CurrentType, from filename: String) -> Current {
        guard filename.isNotEmpty else {
            print("filename is empty, can't load data, returning empty current\n")
            return Current.empty(type: type)
        }
        
        if let current: Current = loadJSONFromDocDir(filename), current.cases.isNotEmpty {
            print("load: current \(current.name) data loaded from \(filename) on disk\n")
            return current
        }
        
        print("current cases from \(filename) are empty, can't load data, returning empty current\n")
        return Current.empty(type: type)
    }
}
