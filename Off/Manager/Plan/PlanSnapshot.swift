//
//  PlanSnapshot.swift
//  Off
//

import Foundation

struct PlanSnapshot: Equatable {

    let firstPlanCreatedAt: Date
    let createdAt: Date
    let preset: PlanPreset?
    let selectedApps: Set<SocialApp>
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
        preset: PlanPreset?,
        selectedApps: Set<SocialApp>,
        name: String,
        timeBoundary: TimeBoundary,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        phoneRestrictionMethod: PhoneRestrictionMethod,
        lightSupports: Set<LightSupport>
    ) {
        self.firstPlanCreatedAt = firstPlanCreatedAt ?? createdAt
        self.createdAt = createdAt
        self.preset = preset
        self.selectedApps = selectedApps
        self.name = name
        self.timeBoundary = timeBoundary
        self.timeWindows = timeWindows
        self.days = days
        self.phoneRestrictionMethod = phoneRestrictionMethod
        self.lightSupports = phoneRestrictionMethod.normalized(lightSupports: lightSupports)
    }

    // Convenience: create from preset (resolves all computed values from it)
    init(preset: PlanPreset, selectedApps: Set<SocialApp>, createdAt: Date, firstPlanCreatedAt: Date? = nil) {
        self.firstPlanCreatedAt = firstPlanCreatedAt ?? createdAt
        self.createdAt = createdAt
        self.preset = preset
        self.selectedApps = selectedApps
        self.name = preset.name
        self.timeBoundary = preset.timeBoundary
        self.timeWindows = preset.timeWindows
        self.days = preset.days
        self.phoneRestrictionMethod = preset.phoneRestrictionMethod
        self.lightSupports = preset.lightSupports
    }

    var displayName: String {
        if let preset { return preset.name }
        return name
    }

    var displayIcon: String {
        PlanVisuals.defaultIcon
    }

    var activeDays: Int {
        max(0, Calendar.current.dateComponents([.day], from: createdAt, to: .now).day ?? 0)
    }
}
