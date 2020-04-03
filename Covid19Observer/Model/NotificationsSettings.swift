//
//  NotificationsSettings.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 03.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

final class NotificationsSettings: ObservableObject {
    func resetAlertData() {
        isAlertScheduled = false
        repeatNotification = false
        notificationWasScheduledAt = .distantPast
    }
    
    var timeSinceScheduled: String { notificationWasScheduledAt.hoursMunutesTillNow }
    
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
    
    
    @Published var repeatNotification: Bool = UserDefaults.standard.bool(forKey: "repeatNotification") {
        didSet {
            UserDefaults.standard.set(repeatNotification, forKey: "repeatNotification")
        }
    }
    
    @Published var selectedTimePeriod: TimePeriod {
        didSet {
            UserDefaults.standard.set(selectedTimePeriod.id, forKey: "selectedTimePeriod")
        }
    }
    
    init() {
        let selectedTimePeriodID = UserDefaults.standard.string(forKey: "selectedTimePeriod") ?? ""
        if selectedTimePeriodID.isEmpty {
            selectedTimePeriod = .twoHours
        } else {
            selectedTimePeriod = TimePeriod(rawValue: selectedTimePeriodID) ?? .twoHours
        }
    }

}
