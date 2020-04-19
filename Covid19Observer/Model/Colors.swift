//
//  Colors.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension Color {
    static var confirmed = Color("confirmed")
    static var new = Color("new")
    static var current = Color("current")
    static var deaths = Color("deaths")
    static var cfr = Color("cfr")
}

extension UIColor {
    static var confirmed = UIColor(named: "confirmed")
    static var new = UIColor(named: "new")
    static var current = UIColor(named: "current")
    static var deaths = UIColor(named: "deaths")
    static var cfr = UIColor(named: "cfr")
}
