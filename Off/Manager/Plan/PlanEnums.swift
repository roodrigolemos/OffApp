//
//  PlanEnums.swift
//  Off
//

import Foundation

enum TimeBoundary: String, Codable, CaseIterable, Hashable {
    case anytime
    case afterTime
    case duringWindows
    case never
}

struct PhoneBehavior: Hashable {
    var removeFromHomeScreen: Bool
    var turnOffNotifications: Bool
    var logOutAccounts: Bool
    var deleteApps: Bool

    static let none = PhoneBehavior(
        removeFromHomeScreen: false,
        turnOffNotifications: false,
        logOutAccounts: false,
        deleteApps: false
    )
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

struct TimeValue: Hashable {
    var hour: Int
    var minute: Int
}

struct TimeWindowValue: Hashable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
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
