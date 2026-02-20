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
    var planHistory: [PlanSnapshot] = []
    var error: PlanError?

    var isPlanDay: Bool {
        guard let plan = activePlan else { return false }
        return plan.days.contains(date: .now)
    }

    var hasCompletedFirstWeeklyCycle: Bool {
        guard let plan = activePlan else { return false }
        let calendar = Calendar.current
        let thisWeekMonday = Date.thisWeekMonday()
        let planStart = calendar.startOfDay(for: plan.firstPlanCreatedAt)
        return planStart < thisWeekMonday
    }

    init(store: PlanStore) {
        self.store = store
    }

    func loadPlan() {
        do {
            planHistory = try store.fetchAllPlans()
            activePlan = planHistory.last
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func createPlan(preset: PlanPreset, selectedApps: Set<SocialApp>) {
        do {
            let snapshot = PlanSnapshot(preset: preset, selectedApps: selectedApps, createdAt: .now)
            try store.save(snapshot)
            loadPlan()
        } catch {
            self.error = .saveFailed
        }
    }

    func changePlan(preset: PlanPreset, selectedApps: Set<SocialApp>) {
        do {
            let snapshot = PlanSnapshot(
                preset: preset,
                selectedApps: selectedApps,
                createdAt: .now,
                firstPlanCreatedAt: activePlan?.firstPlanCreatedAt
            )
            try store.save(snapshot)
            loadPlan()
        } catch {
            self.error = .saveFailed
        }
    }

    func changePlan(
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
                firstPlanCreatedAt: activePlan?.firstPlanCreatedAt,
                createdAt: .now,
                preset: nil,
                selectedApps: selectedApps,
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
            loadPlan()
        } catch {
            self.error = .saveFailed
        }
    }

}
