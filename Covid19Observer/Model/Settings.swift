//
//  Settings.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

final class Settings: ObservableObject {
    
    func resetAlertData() {
        isAlertScheduled = false
        isNotificationRepeated = false
        notificationWasScheduledAt = .distantPast
    }
    
    var hoursMunutesSincenotificationWasScheduledAt: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: notificationWasScheduledAt, to: Date())  ?? "n/a"
    }
    
    var notificationWasScheduledAt: Date = UserDefaults.standard.object(forKey: "notificationWasScheduledAt") as? Date ?? .distantPast {
        didSet {
            UserDefaults.standard.set(notificationWasScheduledAt, forKey: "notificationWasScheduledAt")
        }
    }
    
    @Published var isAlertScheduled: Bool = UserDefaults.standard.bool(forKey: "isAlertScheduled") {
        didSet {
            UserDefaults.standard.set(isAlertScheduled, forKey: "isAlertScheduled")
        }
    }
    
    
    @Published var isNotificationRepeated: Bool = UserDefaults.standard.bool(forKey: "isNotificationRepeated") {
        didSet {
            UserDefaults.standard.set(isNotificationRepeated, forKey: "isNotificationRepeated")
        }
    }
    
    @Published var selectedTimePeriod: TimePeriod {
        didSet {
            UserDefaults.standard.set(selectedTimePeriod.id, forKey: "selectedTimePeriod")
        }
    }
    
    @Published var selectedTab = UserDefaults.standard.integer(forKey: "selectedTab") {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }
    
    @Published var initialNumber: Double {
        didSet {
            UserDefaults.standard.set(initialNumber, forKey: "initialNumber")
        }
    }
    
    init() {
        let savedInitialNumber = UserDefaults.standard.double(forKey: "initialNumber")
        if savedInitialNumber == 0 {
            initialNumber = 5
        } else {
            initialNumber = savedInitialNumber
        }
        
        let selectedTimePeriodID = UserDefaults.standard.string(forKey: "selectedTimePeriod") ?? ""
        if selectedTimePeriodID.isEmpty {
            selectedTimePeriod = .twoHours
        } else {
            selectedTimePeriod = TimePeriod(rawValue: selectedTimePeriodID) ?? .twoHours
        }
    }
}
