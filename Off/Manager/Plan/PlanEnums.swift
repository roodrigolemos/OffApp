//
//  PlanEnums.swift
//  Off
//

import Foundation

enum TimeBoundary: String, Codable, CaseIterable, Hashable {
    case duringWindows
    case always
}

enum PlanVisuals {
    static let defaultIcon = "target"
}

enum PhoneRestrictionMode: String, Codable, CaseIterable, Hashable {
    case none
    case screenTime
    case deleteApps

    var displayName: String {
        switch self {
        case .none: return "No restriction"
        case .screenTime: return "iOS Screen Time shielding"
        case .deleteApps: return "Delete apps from iPhone"
        }
    }

    func normalized(lightSupports: Set<LightSupport>) -> Set<LightSupport> {
        switch self {
        case .none:
            return lightSupports
        case .screenTime:
            return lightSupports.subtracting([.logOut])
        case .deleteApps:
            return []
        }
    }
}

enum LightSupport: String, Codable, CaseIterable, Hashable {
    case notificationsOff
    case removeFromHomeScreen
    case logOut

    var displayName: String {
        switch self {
        case .notificationsOff: return "Turn off notifications"
        case .removeFromHomeScreen: return "Remove from Home Screen"
        case .logOut: return "Log out"
        }
    }
}

struct DaysOfWeek: OptionSet, Codable, Hashable {
    let rawValue: Int

    static let sunday    = DaysOfWeek(rawValue: 1 << 0)
    static let monday    = DaysOfWeek(rawValue: 1 << 1)
    static let tuesday   = DaysOfWeek(rawValue: 1 << 2)
    static let wednesday = DaysOfWeek(rawValue: 1 << 3)
    static let thursday  = DaysOfWeek(rawValue: 1 << 4)
    static let friday    = DaysOfWeek(rawValue: 1 << 5)
    static let saturday  = DaysOfWeek(rawValue: 1 << 6)

    static let weekdays: DaysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekends: DaysOfWeek = [.saturday, .sunday]
    static let everyday: DaysOfWeek = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
}

extension DaysOfWeek {
    func contains(date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let dayMap: [Int: DaysOfWeek] = [
            1: .sunday, 2: .monday, 3: .tuesday,
            4: .wednesday, 5: .thursday, 6: .friday, 7: .saturday
        ]
        guard let day = dayMap[weekday] else { return false }
        return self.contains(day)
    }

    var dayCount: Int {
        var count = 0
        if contains(.sunday) { count += 1 }
        if contains(.monday) { count += 1 }
        if contains(.tuesday) { count += 1 }
        if contains(.wednesday) { count += 1 }
        if contains(.thursday) { count += 1 }
        if contains(.friday) { count += 1 }
        if contains(.saturday) { count += 1 }
        return count
    }
}

struct TimeWindowValue: Hashable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
}

enum PlanTimeWindowRules {
    static let defaultWindow = TimeWindowValue(
        startHour: 9,
        startMinute: 0,
        endHour: 17,
        endMinute: 0
    )

    static func normalized(timeBoundary: TimeBoundary, timeWindows: [TimeWindowValue]) -> [TimeWindowValue] {
        switch timeBoundary {
        case .always:
            return []
        case .duringWindows:
            let firstWindow = timeWindows.first ?? defaultWindow
            return [clamped(window: firstWindow)]
        }
    }

    static func hasValidScheduledWindow(timeBoundary: TimeBoundary, timeWindows: [TimeWindowValue]) -> Bool {
        guard timeBoundary == .duringWindows else { return true }
        guard let window = normalized(timeBoundary: timeBoundary, timeWindows: timeWindows).first else { return false }
        return isValid(window: window)
    }

    static func isValid(window: TimeWindowValue) -> Bool {
        endMinutes(of: window) > startMinutes(of: window)
    }

    private static func clamped(window: TimeWindowValue) -> TimeWindowValue {
        TimeWindowValue(
            startHour: window.startHour.clamped(to: 0...23),
            startMinute: window.startMinute.clamped(to: 0...59),
            endHour: window.endHour.clamped(to: 0...23),
            endMinute: window.endMinute.clamped(to: 0...59)
        )
    }

    private static func startMinutes(of window: TimeWindowValue) -> Int {
        (window.startHour * 60) + window.startMinute
    }

    private static func endMinutes(of window: TimeWindowValue) -> Int {
        (window.endHour * 60) + window.endMinute
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

enum SocialApp: String, Codable, CaseIterable, Hashable {
    case instagram
    case tiktok
    case youtube
    case x
    case facebook
    case reddit
    case snapchat

    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .x: return "X"
        case .facebook: return "Facebook"
        case .reddit: return "Reddit"
        case .snapchat: return "Snapchat"
        }
    }

    var icon: String {
        switch self {
        case .instagram: return "camera"
        case .tiktok: return "music.note"
        case .youtube: return "play.rectangle.fill"
        case .x: return "text.bubble"
        case .facebook: return "person.2.fill"
        case .reddit: return "bubble.left.and.bubble.right.fill"
        case .snapchat: return "bolt.horizontal.circle.fill"
        }
    }
}
