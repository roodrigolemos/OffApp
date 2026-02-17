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
    let icon: String?
    let timeBoundary: TimeBoundary
    let afterTime: TimeValue?
    let timeWindows: [TimeWindowValue]
    let days: DaysOfWeek
    let phoneBehavior: PhoneBehavior
    let condition: String?

    // Full initializer
    init(
        firstPlanCreatedAt: Date? = nil,
        createdAt: Date,
        preset: PlanPreset?,
        selectedApps: Set<SocialApp>,
        name: String,
        icon: String? = nil,
        timeBoundary: TimeBoundary,
        afterTime: TimeValue?,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        phoneBehavior: PhoneBehavior,
        condition: String?,
    ) {
        self.firstPlanCreatedAt = firstPlanCreatedAt ?? createdAt
        self.createdAt = createdAt
        self.preset = preset
        self.selectedApps = selectedApps
        self.name = name
        self.icon = icon
        self.timeBoundary = timeBoundary
        self.afterTime = afterTime
        self.timeWindows = timeWindows
        self.days = days
        self.phoneBehavior = phoneBehavior
        self.condition = condition
    }

    // Convenience: create from preset (resolves all computed values from it)
    init(preset: PlanPreset, selectedApps: Set<SocialApp>, createdAt: Date, firstPlanCreatedAt: Date? = nil) {
        self.firstPlanCreatedAt = firstPlanCreatedAt ?? createdAt
        self.createdAt = createdAt
        self.preset = preset
        self.selectedApps = selectedApps
        self.name = preset.name
        self.icon = nil
        self.timeBoundary = preset.timeBoundary
        self.afterTime = preset.afterTime
        self.timeWindows = preset.timeWindows
        self.days = preset.days
        self.phoneBehavior = preset.phoneBehavior
        self.condition = nil
    }

    var displayName: String {
        if let preset { return preset.name }
        return name
    }

    var displayIcon: String {
        if let preset { return preset.icon }
        return icon ?? "gearshape.fill"
    }

    var activeDays: Int {
        max(0, Calendar.current.dateComponents([.day], from: createdAt, to: .now).day ?? 0)
    }
}
