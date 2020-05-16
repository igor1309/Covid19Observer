//
//  MapOptions.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MapOptions: Codable {
    var isFiltered: Bool = false
    var filterColor: Color {
        Color(MapOptions.colorCode(for: lowerLimit))
    }
    var lowerLimit: Int = 100
    
    static func colorCode(for number: Int) -> UIColor {
        
        let color: UIColor
        
        switch number {
        case 0...99:
            color = .systemGray
        case 100...499:
            color = .systemGreen
        case 500...999:
            color = .systemBlue
        case 1_000...4_999:
            color = .systemYellow
        case 5_000...9_999:
            color = .systemOrange
        case 10_000...:
            color = .systemRed
        default:
            color = .systemFill
        }
        
        return color
    }
}
