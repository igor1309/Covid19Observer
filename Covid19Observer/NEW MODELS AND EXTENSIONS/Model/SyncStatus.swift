//
//  SyncStatus.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import Foundation
import SwiftUI

enum SyncStatus: String {
    case loadFailure = "⚠️ load failed"
    case fetchFailure = "⚠️ fetch failed"
    case loading, loaded, fetching, fetched
    
    private var isNotUpdating: Bool {
        switch self {
        case .fetchFailure, .loadFailure, .loaded, .fetched:
            return true
        case .loading, .fetching:
            return false
        }
    }
    
    var isUpdating: Bool {
        switch self {
        case .fetchFailure, .loadFailure, .loaded, .fetched:
            return false
        case .loading, .fetching:
            return true
        }
    }
    
    func syncText(kind: String, for syncDate: Date, threshold: DateComponents) -> String {
        
        guard self.isNotUpdating else {
            return "…"
        }
        
        if syncDate == .distantPast {
            return "\(kind) data is missing"
        } else if syncDate.hoursMunutesTillNow == "0min" {
            return "\(kind) updated just now."
        } else if syncDate.isDataOld(threshold: threshold) {
            return "\(kind) is old (more than \(syncDate.hoursMunutesTillNowNice))."
        } else {
            return "Last update for \(kind) \(syncDate.hoursMunutesTillNowNice)."
        }
    }
    
    func syncColor(for syncDate: Date, threshold: DateComponents) -> Color {
        
        guard self.isNotUpdating else {
            return .secondary
        }
        
        if syncDate.hoursMunutesTillNow == "0min" {
            return .systemGreen
        } else if syncDate.isDataOld(threshold: threshold) {
            return .systemRed
        } else {
            return .secondary
        }
    }
}
