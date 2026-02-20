//
//  CheckInManager.swift
//  Off
//

import Foundation
import Observation

struct PlanHistoryEntry: Equatable {
    let startDate: Date
    let committedDays: DaysOfWeek
}

struct AdherenceStreakMetrics: Equatable {
    let current: Int
    let bestEver: Int
    let totalDaysFollowed: Int
}

@MainActor
@Observable
final class CheckInManager {

    private let store: CheckInStore

    var checkIns: [CheckInSnapshot] = []
    var weekDays: [WeekDayState] = []
    var weekDayCards: [WeekDayCardData] = []
    var currentStreak: Int = 0
    var error: CheckInError?

    var hasCheckedInToday: Bool {
        checkIns.contains { Calendar.current.isDateInToday($0.date) }
    }

    init(store: CheckInStore) {
        self.store = store
    }

    func boot(plan: PlanSnapshot?, planHistory: [PlanSnapshot] = []) {
        loadCheckIns()
        calculateStreak(plan: plan, planHistory: planHistory)
        calculateWeekDays(plan: plan, planHistory: planHistory)
        calculateWeekDayCards()
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

    func calculateWeekDays(plan: PlanSnapshot?, planHistory: [PlanSnapshot] = []) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday

        let today = calendar.startOfDay(for: .now)
        guard let monday = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }

        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        let history = AdherenceTimeline.history(from: planHistory, fallbackPlan: plan, calendar: calendar)
        let checkInsByDate = AdherenceTimeline.checkInsByDay(checkIns, calendar: calendar)

        var result: [WeekDayState] = []

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: i, to: monday) else { continue }
            let dayStart = calendar.startOfDay(for: day)

            let state: DayAdherenceState

            if dayStart > today {
                state = .upcoming
            } else if let checkIn = checkInsByDate[dayStart] {
                if checkIn.wasPlanDay {
                    switch checkIn.planAdherence {
                    case .yes: state = .followed
                    case .partially: state = .partially
                    case .no, nil: state = .notFollowed
                    }
                } else {
                    switch checkIn.planAdherence {
                    case .yes: state = .followed
                    case .partially: state = .partially
                    case .no, nil: state = .restDay
                    }
                }
            } else if let committedDays = AdherenceTimeline.committedDays(on: dayStart, history: history, calendar: calendar),
                      committedDays.contains(date: dayStart) {
                state = dayStart == today ? .pending : .missed
            } else if dayStart == today {
                state = .pending
            } else {
                state = .restDay
            }

            result.append(WeekDayState(id: i, label: labels[i], state: state))
        }

        weekDays = result
    }

    func calculateWeekDayCards() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let today = calendar.startOfDay(for: .now)
        guard let monday = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }

        let labels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var checkInsByDate: [String: CheckInSnapshot] = [:]
        for checkIn in checkIns {
            checkInsByDate[formatter.string(from: checkIn.date)] = checkIn
        }

        var result: [WeekDayCardData] = []

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: i, to: monday) else { continue }
            let key = formatter.string(from: day)
            let dayStart = calendar.startOfDay(for: day)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"

            result.append(WeekDayCardData(
                id: i,
                dayLabel: labels[i],
                dateNumber: dateFormatter.string(from: day),
                isToday: dayStart == today,
                checkIn: checkInsByDate[key]
            ))
        }

        weekDayCards = result
    }

    func calculateStreak(plan: PlanSnapshot?, planHistory: [PlanSnapshot] = []) {
        let metrics = streakMetrics(plan: plan, planHistory: planHistory)
        currentStreak = metrics.current
    }

    func streakMetrics(plan: PlanSnapshot?, planHistory: [PlanSnapshot] = []) -> AdherenceStreakMetrics {
        let history = AdherenceTimeline.history(from: planHistory, fallbackPlan: plan, calendar: .current)
        return AdherenceTimeline.streakMetrics(checkIns: checkIns, history: history, calendar: .current, now: .now)
    }
}

private enum AdherenceTimeline {

    static func history(from plans: [PlanSnapshot], fallbackPlan: PlanSnapshot?, calendar: Calendar) -> [PlanHistoryEntry] {
        let sourcePlans = plans.isEmpty ? (fallbackPlan.map { [$0] } ?? []) : plans
        let sorted = sourcePlans.sorted { $0.createdAt < $1.createdAt }
        var byStartDay: [Date: PlanHistoryEntry] = [:]

        for plan in sorted {
            let day = calendar.startOfDay(for: plan.createdAt)
            byStartDay[day] = PlanHistoryEntry(startDate: day, committedDays: plan.days)
        }

        return byStartDay.values.sorted { $0.startDate < $1.startDate }
    }

    static func committedDays(on date: Date, history: [PlanHistoryEntry], calendar: Calendar) -> DaysOfWeek? {
        let day = calendar.startOfDay(for: date)
        return history.last(where: { $0.startDate <= day })?.committedDays
    }

    static func checkInsByDay(_ checkIns: [CheckInSnapshot], calendar: Calendar) -> [Date: CheckInSnapshot] {
        var dict: [Date: CheckInSnapshot] = [:]
        for checkIn in checkIns {
            dict[calendar.startOfDay(for: checkIn.date)] = checkIn
        }
        return dict
    }

    static func streakMetrics(
        checkIns: [CheckInSnapshot],
        history: [PlanHistoryEntry],
        calendar: Calendar,
        now: Date
    ) -> AdherenceStreakMetrics {
        guard let start = history.first?.startDate else {
            return AdherenceStreakMetrics(current: 0, bestEver: 0, totalDaysFollowed: 0)
        }

        let today = calendar.startOfDay(for: now)
        let byDay = checkInsByDay(checkIns, calendar: calendar)

        var currentStreak = 0
        var bestEver = 0
        var totalFollowed = 0
        var cursor = start

        while cursor <= today {
            let checkIn = byDay[cursor]
            let committedMask = committedDays(on: cursor, history: history, calendar: calendar)
            let isCommitted = committedMask?.contains(date: cursor) ?? false
            let isToday = calendar.isDate(cursor, inSameDayAs: today)

            if let adherence = checkIn?.planAdherence {
                switch adherence {
                case .yes, .partially:
                    currentStreak += 1
                    bestEver = max(bestEver, currentStreak)
                    totalFollowed += 1
                case .no:
                    if isCommitted {
                        currentStreak = 0
                    }
                }
            } else if checkIn != nil {
                if isCommitted {
                    currentStreak = 0
                }
            } else if isCommitted && !isToday {
                currentStreak = 0
            }

            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? today
        }

        return AdherenceStreakMetrics(current: currentStreak, bestEver: bestEver, totalDaysFollowed: totalFollowed)
    }
}
