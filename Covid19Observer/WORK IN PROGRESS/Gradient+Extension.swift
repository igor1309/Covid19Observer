//
//  Gradient+Extension.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 08.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension Gradient {
    static let temperetureGradient = Gradient(colors: [
        .purple,
        Color(red: 0, green: 0, blue: 139.0/255.0),
        .blue,
        Color(red: 30.0/255.0, green: 144.0/255.0, blue: 1.0),
        Color(red: 0, green: 191/255.0, blue: 1.0),
        Color(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0),
        .green,
        .yellow,
        .orange,
        Color(red: 1.0, green: 140.0/255.0, blue: 0.0),
        .red,
        Color(red: 139.0/255.0, green: 0.0, blue: 0.0)
    ])
}
