//
//  Plan.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class Plan {
    
    var presetRawValue: String
    var selectedAppsRaw: [String]
    var createdAt: Date

    init(presetRawValue: String, selectedAppsRaw: [String], createdAt: Date) {
        self.presetRawValue = presetRawValue
        self.selectedAppsRaw = selectedAppsRaw
        self.createdAt = createdAt
    }

    init(from snapshot: PlanSnapshot) {
        self.presetRawValue = snapshot.preset?.rawValue ?? ""
        self.selectedAppsRaw = snapshot.selectedApps.map(\.rawValue)
        self.createdAt = snapshot.createdAt
    }

    func toSnapshot() -> PlanSnapshot {
        PlanSnapshot(
            preset: PlanPreset(rawValue: presetRawValue),
            selectedApps: Set(selectedAppsRaw.compactMap { SocialApp(rawValue: $0) }),
            createdAt: createdAt
        )
    }
}
