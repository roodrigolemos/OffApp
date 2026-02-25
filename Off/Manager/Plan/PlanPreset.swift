//
//  PlanPreset.swift
//  Off
//

import Foundation

enum PlanPreset: String, CaseIterable, Identifiable, Hashable {
    case weekdayDetox
    case lunchBreakOnly

    var id: String { rawValue }

    var name: String {
        switch self {
        case .weekdayDetox: return "Weekday Detox"
        case .lunchBreakOnly: return "Lunch Break Only"
        }
    }

    var icon: String {
        switch self {
        case .weekdayDetox: return "briefcase.fill"
        case .lunchBreakOnly: return "fork.knife"
        }
    }

    var subtitle: String {
        switch self {
        case .weekdayDetox: return "Stay focused on weekdays."
        case .lunchBreakOnly: return "Allow only during lunch."
        }
    }

    var detail: String {
        switch self {
        case .weekdayDetox: return "When: never\nDays: Mon–Fri\nPhone: delete apps"
        case .lunchBreakOnly: return "When: 12–1 PM\nDays: every day\nPhone: hidden + silent"
        }
    }

    var timeBoundary: TimeBoundary {
        switch self {
        case .weekdayDetox: return .never
        case .lunchBreakOnly: return .duringWindows
        }
    }

    var timeWindows: [TimeWindowValue] {
        switch self {
        case .weekdayDetox: return []
        case .lunchBreakOnly: return [TimeWindowValue(startHour: 12, startMinute: 0, endHour: 13, endMinute: 0)]
        }
    }

    var days: DaysOfWeek {
        switch self {
        case .weekdayDetox: return .weekdays
        case .lunchBreakOnly: return .everyday
        }
    }

    var phoneBehavior: PhoneBehavior {
        switch self {
        case .weekdayDetox:
            return PhoneBehavior(removeFromHomeScreen: false, turnOffNotifications: false, logOutAccounts: false, deleteApps: true)
        case .lunchBreakOnly:
            return PhoneBehavior(removeFromHomeScreen: true, turnOffNotifications: true, logOutAccounts: false, deleteApps: false)
        }
    }
}
