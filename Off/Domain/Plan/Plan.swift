//
//  Plan.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class Plan {

    var firstPlanCreatedAt: Date
    var createdAt: Date
    var presetRawValue: String
    var selectedAppsRaw: [String]

    var name: String
    var timeBoundaryRaw: String
    var afterTimeHour: Int?
    var afterTimeMinute: Int?
    var timeWindowsData: [[String: Int]]
    var daysRaw: Int
    var removeFromHomeScreen: Bool
    var turnOffNotifications: Bool
    var logOutAccounts: Bool
    var deleteApps: Bool
    var condition: String?
    var icon: String?

    init(from snapshot: PlanSnapshot) {
        self.firstPlanCreatedAt = snapshot.firstPlanCreatedAt
        self.presetRawValue = snapshot.preset?.rawValue ?? ""
        self.selectedAppsRaw = snapshot.selectedApps.map(\.rawValue)
        self.createdAt = snapshot.createdAt
        self.name = snapshot.name
        self.timeBoundaryRaw = snapshot.timeBoundary.rawValue
        self.afterTimeHour = snapshot.afterTime?.hour
        self.afterTimeMinute = snapshot.afterTime?.minute
        self.timeWindowsData = snapshot.timeWindows.map { tw in
            ["sh": tw.startHour, "sm": tw.startMinute, "eh": tw.endHour, "em": tw.endMinute]
        }
        self.daysRaw = snapshot.days.rawValue
        self.removeFromHomeScreen = snapshot.phoneBehavior.removeFromHomeScreen
        self.turnOffNotifications = snapshot.phoneBehavior.turnOffNotifications
        self.logOutAccounts = snapshot.phoneBehavior.logOutAccounts
        self.deleteApps = snapshot.phoneBehavior.deleteApps
        self.condition = snapshot.condition
        self.icon = snapshot.icon
    }

    func toSnapshot() -> PlanSnapshot {
        let afterTime: TimeValue?
        if let h = afterTimeHour, let m = afterTimeMinute {
            afterTime = TimeValue(hour: h, minute: m)
        } else {
            afterTime = nil
        }

        let windows = timeWindowsData.compactMap { dict -> TimeWindowValue? in
            guard let sh = dict["sh"], let sm = dict["sm"],
                  let eh = dict["eh"], let em = dict["em"] else { return nil }
            return TimeWindowValue(startHour: sh, startMinute: sm, endHour: eh, endMinute: em)
        }

        let behavior = PhoneBehavior(
            removeFromHomeScreen: removeFromHomeScreen,
            turnOffNotifications: turnOffNotifications,
            logOutAccounts: logOutAccounts,
            deleteApps: deleteApps
        )

        return PlanSnapshot(
            firstPlanCreatedAt: firstPlanCreatedAt,
            createdAt: createdAt,
            preset: PlanPreset(rawValue: presetRawValue),
            selectedApps: Set(selectedAppsRaw.compactMap { SocialApp(rawValue: $0) }),
            name: name,
            icon: icon,
            timeBoundary: TimeBoundary(rawValue: timeBoundaryRaw) ?? .anytime,
            afterTime: afterTime,
            timeWindows: windows,
            days: DaysOfWeek(rawValue: daysRaw),
            phoneBehavior: behavior,
            condition: condition
        )
    }
}
