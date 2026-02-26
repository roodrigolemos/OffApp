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
    var timeWindowsData: [[String: Int]]
    var daysRaw: Int
    var phoneRestrictionMethodRaw: String
    var lightSupportsRaw: [String]

    init(from snapshot: PlanSnapshot) {
        self.firstPlanCreatedAt = snapshot.firstPlanCreatedAt
        self.presetRawValue = snapshot.preset?.rawValue ?? ""
        self.selectedAppsRaw = snapshot.selectedApps.map(\.rawValue)
        self.createdAt = snapshot.createdAt
        self.name = snapshot.name
        self.timeBoundaryRaw = snapshot.timeBoundary.rawValue
        self.timeWindowsData = snapshot.timeWindows.map { tw in
            ["sh": tw.startHour, "sm": tw.startMinute, "eh": tw.endHour, "em": tw.endMinute]
        }
        self.daysRaw = snapshot.days.rawValue
        self.phoneRestrictionMethodRaw = snapshot.phoneRestrictionMethod.rawValue
        self.lightSupportsRaw = snapshot.lightSupports.map(\.rawValue)
    }

    func toSnapshot() -> PlanSnapshot? {
        guard let timeBoundary = TimeBoundary(rawValue: timeBoundaryRaw) else {
            return nil
        }

        let windows = timeWindowsData.compactMap { dict -> TimeWindowValue? in
            guard let sh = dict["sh"], let sm = dict["sm"],
                  let eh = dict["eh"], let em = dict["em"] else { return nil }
            return TimeWindowValue(startHour: sh, startMinute: sm, endHour: eh, endMinute: em)
        }

        let restrictionMethod = PhoneRestrictionMethod(rawValue: phoneRestrictionMethodRaw) ?? .none
        let lightSupports = Set(lightSupportsRaw.compactMap { LightSupport(rawValue: $0) })
        let normalizedLightSupports = restrictionMethod.normalized(lightSupports: lightSupports)

        return PlanSnapshot(
            firstPlanCreatedAt: firstPlanCreatedAt,
            createdAt: createdAt,
            preset: PlanPreset(rawValue: presetRawValue),
            selectedApps: Set(selectedAppsRaw.compactMap { SocialApp(rawValue: $0) }),
            name: name,
            timeBoundary: timeBoundary,
            timeWindows: windows,
            days: DaysOfWeek(rawValue: daysRaw),
            phoneRestrictionMethod: restrictionMethod,
            lightSupports: normalizedLightSupports
        )
    }
}
