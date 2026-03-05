//
//  UsageManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class UsageManager {

    var snapshot = UsageProgressSnapshot(state: .lockedTracking)

    func recalculate(
        activePlan: PlanSnapshot?,
        trackingState: UsageTrackingState,
        now: Date = .now
    ) {
        guard let activePlan else {
            snapshot = UsageProgressSnapshot(state: .lockedTracking)
            return
        }

        switch activePlan.phoneRestrictionMode {
        case .deleteApps:
            snapshot = UsageProgressSnapshot(
                state: .removalImpact(daysSinceRemoval: daysBetween(activePlan.createdAt, now: now))
            )
        case .none:
            let state: UsageProgressState = (trackingState.isAuthorized && trackingState.hasSelection)
                ? .usageEnabled
                : .lockedTracking
            snapshot = UsageProgressSnapshot(state: state)
        case .screenTime:
            if !trackingState.isAuthorized {
                snapshot = UsageProgressSnapshot(state: .requiredScreenTimePermission)
            } else if !trackingState.hasSelection {
                snapshot = UsageProgressSnapshot(state: .requiredSelection)
            } else {
                snapshot = UsageProgressSnapshot(state: .usageEnabled)
            }
        }
    }
}

private extension UsageManager {

    func daysBetween(_ date: Date, now: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.startOfDay(for: now)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }
}
