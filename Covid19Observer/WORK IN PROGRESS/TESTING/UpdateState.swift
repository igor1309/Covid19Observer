//
//  UpdateState.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 22.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation

enum UpdateState {
    case success(Date)
    case failure
    
    var timeSinceUpdate: String? {
        switch self {
        case .success(let date):
            return date.hoursMunutesTillNow
        case .failure:
            return nil
        }
    }
}
