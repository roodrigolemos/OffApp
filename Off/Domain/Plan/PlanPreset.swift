//
//  PlanPreset.swift
//  Off
//

import Foundation

enum PlanPreset: String, CaseIterable, Identifiable, Hashable {
    case eveningWindDown
    case weekdayDetox
    case lunchBreakOnly
    case purposeFirst
    case morningFocus

    var id: String { rawValue }

    var name: String {
        switch self {
        case .eveningWindDown: return "Evening Wind-Down"
        case .weekdayDetox: return "Weekday Detox"
        case .lunchBreakOnly: return "Lunch Break Only"
        case .purposeFirst: return "Purpose First"
        case .morningFocus: return "Morning Focus"
        }
    }

    var icon: String {
        switch self {
        case .eveningWindDown: return "moon.stars.fill"
        case .weekdayDetox: return "briefcase.fill"
        case .lunchBreakOnly: return "fork.knife"
        case .purposeFirst: return "target"
        case .morningFocus: return "sunrise.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .eveningWindDown: return "Wind down before bed."
        case .weekdayDetox: return "Stay focused on weekdays."
        case .lunchBreakOnly: return "Allow only during lunch."
        case .purposeFirst: return "Social after priorities."
        case .morningFocus: return "No social until afternoon."
        }
    }

    var detail: String {
        switch self {
        case .eveningWindDown: return "When: after 8 PM\nDays: every day\nPhone: log out"
        case .weekdayDetox: return "When: never\nDays: Mon–Fri\nPhone: delete apps"
        case .lunchBreakOnly: return "When: 12–1 PM\nDays: every day\nPhone: hidden + silent"
        case .purposeFirst: return "Condition: after tasks done\nDays: every day\nPhone: silent"
        case .morningFocus: return "When: after 12 PM\nDays: Mon–Fri\nPhone: hidden"
        }
    }

    var timeBoundary: TimeBoundary {
        switch self {
        case .eveningWindDown: return .afterTime
        case .weekdayDetox: return .never
        case .lunchBreakOnly: return .duringWindows
        case .purposeFirst: return .afterTime
        case .morningFocus: return .afterTime
        }
    }

    var afterTime: TimeValue? {
        switch self {
        case .eveningWindDown: return TimeValue(hour: 20, minute: 0)
        case .weekdayDetox: return nil
        case .lunchBreakOnly: return nil
        case .purposeFirst: return nil
        case .morningFocus: return TimeValue(hour: 12, minute: 0)
        }
    }

    var timeWindows: [TimeWindowValue] {
        switch self {
        case .lunchBreakOnly: return [TimeWindowValue(startHour: 12, startMinute: 0, endHour: 13, endMinute: 0)]
        default: return []
        }
    }

    var days: DaysOfWeek {
        switch self {
        case .eveningWindDown: return .everyday
        case .weekdayDetox: return .weekdays
        case .lunchBreakOnly: return .everyday
        case .purposeFirst: return .everyday
        case .morningFocus: return .weekdays
        }
    }

    var phoneBehavior: PhoneBehavior {
        switch self {
        case .eveningWindDown:
            return PhoneBehavior(removeFromHomeScreen: false, turnOffNotifications: false, logOutAccounts: true, deleteApps: false)
        case .weekdayDetox:
            return PhoneBehavior(removeFromHomeScreen: false, turnOffNotifications: false, logOutAccounts: false, deleteApps: true)
        case .lunchBreakOnly:
            return PhoneBehavior(removeFromHomeScreen: true, turnOffNotifications: true, logOutAccounts: false, deleteApps: false)
        case .purposeFirst:
            return PhoneBehavior(removeFromHomeScreen: false, turnOffNotifications: true, logOutAccounts: false, deleteApps: false)
        case .morningFocus:
            return PhoneBehavior(removeFromHomeScreen: true, turnOffNotifications: false, logOutAccounts: false, deleteApps: false)
        }
    }
}
