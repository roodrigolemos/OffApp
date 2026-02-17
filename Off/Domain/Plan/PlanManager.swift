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
    var currentStreak: Int = 0

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
            let snapshot = PlanSnapshot(
                preset: preset,
                selectedApps: selectedApps,
                createdAt: .now,
                firstPlanCreatedAt: activePlan?.firstPlanCreatedAt
            )
            try store.save(snapshot)
            activePlan = snapshot
            error = nil
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
            activePlan = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func calculateStreak(checkIns: [CheckInSnapshot]) {
        guard let plan = activePlan else {
            currentStreak = 0
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let startDate = calendar.startOfDay(for: plan.firstPlanCreatedAt)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var checkInByDate: [String: CheckInSnapshot] = [:]
        for checkIn in checkIns {
            let key = formatter.string(from: checkIn.date)
            checkInByDate[key] = checkIn
        }

        var streak = 0
        var current = startDate

        while current <= today {
            let key = formatter.string(from: current)
            let checkIn = checkInByDate[key]
            let isPlanDay = plan.days.contains(date: current)
            let isToday = calendar.isDateInToday(current)

            if isPlanDay {
                if let adherence = checkIn?.planAdherence {
                    switch adherence {
                    case .yes, .partially:
                        streak += 1
                    case .no:
                        streak = 0
                    }
                } else if isToday {
                    // Grace period — keep current streak
                } else {
                    streak = 0
                }
            } else {
                if let checkIn {
                    if let adherence = checkIn.planAdherence {
                        switch adherence {
                        case .yes, .partially:
                            streak += 1
                        case .no:
                            break // skip, no impact
                        }
                    }
                    // No adherence → skip
                }
                // No check-in on non-plan day → skip
            }

            current = calendar.date(byAdding: .day, value: 1, to: current) ?? today
        }

        currentStreak = streak
    }

}
