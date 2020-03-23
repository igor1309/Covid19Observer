//
//  DoublingData.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

final class DoublingData: ObservableObject {
    @Published var initialNumber = UserDefaults.standard.double(forKey: "initialNumber") {
        didSet {
            UserDefaults.standard.set(initialNumber, forKey: "initialNumber")
        }
    }
}
