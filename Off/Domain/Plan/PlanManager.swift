//
//  PlanManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class PlanManager {

    private let store: PlanStore

    var activePlan: PlanSnapshot?
    var error: PlanError?

    var isPlanDay: Bool {
        guard let plan = activePlan else { return false }
        return plan.days.contains(date: .now)
    }

    init(store: PlanStore) {
        self.store = store
    }

    func loadPlan() {
        do {
            activePlan = try store.fetchActivePlan()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func createPlan(preset: PlanPreset, selectedApps: Set<SocialApp>) {
        do {
            let snapshot = PlanSnapshot(preset: preset, selectedApps: selectedApps, createdAt: .now)
            try store.save(snapshot)
            activePlan = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func changePlan(preset: PlanPreset, selectedApps: Set<SocialApp>) {
        do {
            let snapshot = PlanSnapshot(preset: preset, selectedApps: selectedApps, createdAt: .now)
            try store.save(snapshot)
            activePlan = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func createCustomPlan(
        name: String,
        icon: String?,
        selectedApps: Set<SocialApp>,
        timeBoundary: TimeBoundary,
        afterTime: TimeValue?,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        phoneBehavior: PhoneBehavior,
        condition: String?
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            error = .invalidPlanName
            return
        }
        guard days.dayCount >= 4 else {
            error = .notEnoughDays
            return
        }
        guard !selectedApps.isEmpty else {
            error = .noAppsSelected
            return
        }

        do {
            let snapshot = PlanSnapshot(
                preset: nil,
                selectedApps: selectedApps,
                createdAt: .now,
                name: trimmed,
                icon: icon,
                timeBoundary: timeBoundary,
                afterTime: afterTime,
                timeWindows: timeWindows,
                days: days,
                phoneBehavior: phoneBehavior,
                condition: condition
            )
            try store.save(snapshot)
            activePlan = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }
}
