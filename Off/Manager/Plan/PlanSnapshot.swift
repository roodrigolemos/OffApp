//
//  PlanSnapshot.swift
//  Off
//

import Foundation

struct PlanSnapshot: Equatable {

    let firstPlanCreatedAt: Date
    let createdAt: Date
    let name: String
    let timeBoundary: TimeBoundary
    let timeWindows: [TimeWindowValue]
    let days: DaysOfWeek
    let phoneRestrictionMethod: PhoneRestrictionMethod
    let lightSupports: Set<LightSupport>

    // Full initializer
    init(
        firstPlanCreatedAt: Date? = nil,
        createdAt: Date,
        name: String,
        timeBoundary: TimeBoundary,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        phoneRestrictionMethod: PhoneRestrictionMethod,
        lightSupports: Set<LightSupport>
    ) {
        self.firstPlanCreatedAt = firstPlanCreatedAt ?? createdAt
        self.createdAt = createdAt
        self.name = name
        self.timeBoundary = timeBoundary
        self.timeWindows = timeWindows
        self.days = days
        self.phoneRestrictionMethod = phoneRestrictionMethod
        self.lightSupports = phoneRestrictionMethod.normalized(lightSupports: lightSupports)
    }

    var displayName: String {
        return name
    }

    var displayIcon: String {
        PlanVisuals.defaultIcon
    }

    var activeDays: Int {
        max(0, Calendar.current.dateComponents([.day], from: createdAt, to: .now).day ?? 0)
    }
}
