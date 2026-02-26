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

    var subtitle: String {
        switch self {
        case .weekdayDetox: return "Stay focused on weekdays."
        case .lunchBreakOnly: return "Allow only during lunch."
        }
    }

    var detail: String {
        switch self {
        case .weekdayDetox: return "When: never\nDays: Mon–Fri\nPhone restriction: delete apps"
        case .lunchBreakOnly: return "When: 12–1 PM\nDays: every day\nPhone restriction: iOS Screen Time + light supports"
        }
    }

    var timeBoundary: TimeBoundary {
        switch self {
        case .weekdayDetox: return .always
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

    var phoneRestrictionMethod: PhoneRestrictionMethod {
        switch self {
        case .weekdayDetox: return .deleteApps
        case .lunchBreakOnly: return .screenTime
        }
    }

    var lightSupports: Set<LightSupport> {
        switch self {
        case .weekdayDetox:
            return []
        case .lunchBreakOnly:
            return [.notificationsOff, .removeFromHomeScreen]
        }
    }
}
