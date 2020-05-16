//
//  Ext+Outbreak.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

extension Outbreak {
    init(population: Int, currentByCountry: Current, confirmedHistory: Historical, deathsHistory: Historical) {
                
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0
        
        for cases in currentByCountry.cases {
            totalCases += cases.confirmed
            totalDeaths += cases.deaths
            totalRecovered += cases.recovered
        }
        
        //  MARK: count new and current cases
        var totalConfirmedNew = 0
        var totalConfirmedCurrent = 0
        
        var totalDeathsNew = 0
        var totalDeathsCurrent = 0
        
        for index in currentByCountry.cases.indices {
            
            let name = currentByCountry.cases[index].name
            
            //  Confirmed Cases
            
            let confirmedLast = confirmedHistory.last(for: name)
            let confirmedPrevious = confirmedHistory.previous(for: name)
            
            let confirmedNew = confirmedLast - confirmedPrevious
            let comfirmedCurrent = currentByCountry.cases[index].confirmed - confirmedLast
            
            totalConfirmedNew += confirmedNew
            totalConfirmedCurrent += comfirmedCurrent
            
            
            //  Deaths
            
            let deathsLast = deathsHistory.last(for: name)
            let deathsPrevious = deathsHistory.previous(for: name)
            
            let deathsNew = deathsLast - deathsPrevious
            let deathsCurrent = currentByCountry.cases[index].deaths - deathsLast
            
            totalDeathsNew += deathsNew
            totalDeathsCurrent += deathsCurrent
        }
        
        self.init(population: population,
                  confirmed: totalCases,
                  confirmedNew: totalConfirmedNew,
                  confirmedCurrent: totalConfirmedCurrent,
                  recovered: totalRecovered,
                  deaths: totalDeaths,
                  deathsNew: totalDeathsNew,
                  deathsCurrent: totalDeathsCurrent)
    }
}
