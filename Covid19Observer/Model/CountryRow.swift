//
//  CountryRow.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CountryRow: Codable, Identifiable {
    var id: String { provinceState + "/" + countryRegion }
    
    var name: String {
        provinceState.isEmpty
            ? countryRegion
            : provinceState + "/" + countryRegion }

    var provinceState, countryRegion: String
//    let latitude, longitude: Double

    /// точки «дата—значение»
    //  MARK: РЕШИТЬ, НУЖНО ЛИ ИЛИ УБРАТЬ
    var points: [Date: Int]
    
    /// значения confirmed или deaths, исп как значения на оси Y
    /// значения по оси X хранятся в структуре History
    var series: [Int]
    
    /// скрыть/показать график
    var isHidden: Bool = false
}
