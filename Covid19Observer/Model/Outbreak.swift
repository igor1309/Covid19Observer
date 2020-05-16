//
//  Outbreak.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftPI

struct Outbreak: Codable {
    
    /// `Population` - world or country
    
    var population: Int = 0
    
    ///  `Confirmed Cases`
    
    var confirmed: Int = 0
    var confirmedNew: Int = 0
    var confirmedCurrent: Int = 0
    
    ///  `Recovered`
    
    var recovered: Int = 0
    
    ///  `Deaths`
    
    var deaths: Int = 0
    var deathsNew: Int = 0
    var deathsCurrent: Int = 0
}

    
//  MARK: - Percentages calculations and properties for Views: …Str: String
extension Outbreak {
    
    /// `Population` - world or country
    
    var populationStr: String { population.formattedGrouped }
    
    ///  `Confirmed Cases`
    
    var confirmedStr: String { confirmed.formattedGrouped }
    var confirmedNewStr: String { confirmedNew.formattedGrouped }
    var confirmedCurrentStr: String { confirmedCurrent.formattedGrouped }
    
    var confirmedToPopulation: Double { population == 0 ? 0 : Double(confirmed) / Double(population) }
    var confirmedToPopulationStr: String { confirmedToPopulation.formattedPercentageWithDecimals }
    
    var confirmedNewToConfirmed: Double {
        let base = confirmed - confirmedNew - confirmedCurrent
        return base == 0 ? 0 : Double(confirmedNew) / Double(base)
    }
    var confirmedNewToConfirmedStr: String { confirmedNewToConfirmed.formattedPercentageWithDecimals }

    var confirmedCurrentToConfirmed: Double {
        let base = confirmed - confirmedCurrent
        return base == 0 ? 0 : Double(confirmedCurrent) / Double(base)
    }
    var confirmedCurrentToConfirmedStr: String { confirmedCurrentToConfirmed.formattedPercentageWithDecimals }
    
    ///  `Recovered`
    
    var recoveredStr: String { recovered.formattedGrouped }
    
    var recoveredToConfirmed: Double { Double(recovered) / Double(confirmed) }
    var recoveredToConfirmedStr: String { recoveredToConfirmed.formattedPercentageWithDecimals }

    ///  `Deaths`
    
    var deathsStr: String { deaths.formattedGrouped }
    var deathsNewStr: String { deathsNew.formattedGrouped }
    var deathsCurrentStr: String { deathsCurrent.formattedGrouped }
    
    var deathsToPopulation: Double { Double(deaths) / Double(population) }
    var deathsToPopulationStr: String { deathsToPopulation.formattedPercentageWithDecimals }
    
    var deathsNewToDeaths: Double {
        let base = deaths - deathsNew - deathsCurrent
        return base == 0 ? 0 : Double(deathsNew) / Double(base)
    }
    var deathsNewToDeathsStr: String { deathsNewToDeaths.formattedPercentageWithDecimals }

    var deathsCurrentToDeaths: Double {
        let base = deaths - deathsCurrent
        return base == 0 ? 0 : Double(deathsCurrent) / Double(base)
    }
    var deathsCurrentToDeathsStr: String { deathsCurrentToDeaths.formattedPercentageWithDecimals }
    
    var deathsPerMillion: Double { Double(deaths) * 1_000_000 / Double(population) }
    var deathsPerMillionStr: String { "\(deathsPerMillion.formattedGrouped) per 1m" }
    
    ///  `Case Fatality Rate`
    
    var cfr: Double { confirmed == 0 ? 0 : Double(deaths) / Double(confirmed) }
    var cfrStr: String { cfr.formattedPercentageWithDecimals}
}


