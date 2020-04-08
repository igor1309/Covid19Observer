//
//  Array+Ext.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 08.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

extension Array where Array.Element: Equatable {
    func deletingPrefix(_ prefix: Array.Element) -> Array {
        guard self.first == prefix else { return self }
        return Array(self.dropFirst())
    }
}
