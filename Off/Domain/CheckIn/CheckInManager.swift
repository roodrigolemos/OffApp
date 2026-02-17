//
//  CheckInManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class CheckInManager {

    private let store: CheckInStore

    var checkIns: [CheckInSnapshot] = []
    var weekDays: [WeekDayState] = []
    var currentStreak: Int = 0
    var error: CheckInError?

    var hasCheckedInToday: Bool {
        checkIns.contains { Calendar.current.isDateInToday($0.date) }
    }

    init(store: CheckInStore) {
        self.store = store
    }

    func boot(plan: PlanSnapshot?) {
        loadCheckIns()
        calculateStreak(plan: plan)
        calculateWeekDays(plan: plan)
    }

    func loadCheckIns() {
        do {
            checkIns = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func save(_ snapshot: CheckInSnapshot) {
        do {
            try store.save(snapshot)
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func calculateWeekDays(plan: PlanSnapshot?) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday

        let today = calendar.startOfDay(for: .now)
        guard let monday = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }

        let labels = ["M", "T", "W", "T", "F", "S", "S"]

        let checkInsByDate: [String: CheckInSnapshot] = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var dict: [String: CheckInSnapshot] = [:]
            for checkIn in checkIns {
                dict[formatter.string(from: checkIn.date)] = checkIn
            }
            return dict
        }()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var result: [WeekDayState] = []

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: i, to: monday) else { continue }
            let dayStart = calendar.startOfDay(for: day)
            let key = formatter.string(from: day)

            let state: DayAdherenceState

            guard let plan else {
                state = .restDay
                result.append(WeekDayState(id: i, label: labels[i], state: state))
                continue
            }

            let isPlanDay = plan.days.contains(date: day)

            if !isPlanDay {
                state = .restDay
            } else if dayStart < calendar.startOfDay(for: plan.firstPlanCreatedAt) {
                state = .restDay
            } else if let checkIn = checkInsByDate[key] {
                switch checkIn.planAdherence {
                case .yes: state = .followed
                case .partially: state = .partially
                case .no: state = .notFollowed
                case nil: state = .followed
                }
            } else if dayStart > today {
                state = .upcoming
            } else if dayStart == today {
                state = .pending
            } else {
                state = .missed
            }

            result.append(WeekDayState(id: i, label: labels[i], state: state))
        }

        weekDays = result
    }

    func calculateStreak(plan: PlanSnapshot?) {
        guard let plan else {
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
