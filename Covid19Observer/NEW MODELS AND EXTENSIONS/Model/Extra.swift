//
//  Extra.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

struct Extra: Codable, Equatable {
    var newAndCurrents: [NewAndCurrent]
}

extension Extra {
    init(coronaByCountry: Current, confirmedHistory: Historical, deathsHistory: Historical) {
        
        var newAndCurrentArray = [NewAndCurrent]()
        
        for index in coronaByCountry.cases.indices {
            let name = coronaByCountry.cases[index].name
            
            ///  `Confirmed Cases`
            
            let confirmedLast = confirmedHistory.last(for: name)
            let confirmedPrevious = confirmedHistory.previous(for: name)
            
            let confirmedNew = confirmedLast - confirmedPrevious
            
            let comfirmedCurrent = coronaByCountry.cases[index].confirmed - confirmedLast
            
            ///  `Deaths`
            
            let deathsLast = deathsHistory.last(for: name)
            let deathsPrevious = deathsHistory.previous(for: name)
            
            let deathsNew = deathsLast - deathsPrevious
            
            let deathsCurrent = coronaByCountry.cases[index].deaths - deathsLast
            
            newAndCurrentArray.append(
                NewAndCurrent(name: name,
                              confirmedNew: confirmedNew,
                              confirmedCurrent: comfirmedCurrent,
                              deathsNew: deathsNew,
                              deathsCurrent: deathsCurrent))
        }
        
        self.init(newAndCurrents: newAndCurrentArray)
    }
}
