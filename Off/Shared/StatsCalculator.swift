//
//  StatsCalculator.swift
//  Off
//

import Foundation

struct AdherenceStreakMetrics: Equatable {
    let current: Int
    let bestEver: Int
    let totalDaysFollowed: Int
}

enum AdherenceCellState: Equatable {
    case padding
    case inactive
    case committedFollowed
    case committedMissed
    case offFollowed
    case offNeutral
    case todayNeutral
}

struct AdherenceDayCell: Identifiable, Equatable {
    let id: String
    let date: Date?
    let state: AdherenceCellState
}

struct AdherenceMonth: Identifiable, Equatable {
    let id: String
    let displayName: String
    let cells: [AdherenceDayCell]
    let numerator: Int
    let denominator: Int
    let percentage: Int
}

private struct PlanHistoryEntry: Equatable {
    let startDate: Date
    let committedDays: DaysOfWeek
}

enum StatsCalculator {

    static func streakMetrics(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        now: Date = .now
    ) -> AdherenceStreakMetrics {
        let calendar = mondayCalendar()
        let history = planHistoryEntries(plans: planHistory, fallbackPlan: activePlan, calendar: calendar)
        return streakMetrics(checkIns: checkIns, history: history, calendar: calendar, now: now)
    }

    static func weekDays(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        now: Date = .now
    ) -> [WeekDayState] {
        let calendar = mondayCalendar()
        let today = calendar.startOfDay(for: now)
        guard let monday = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }

        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        let history = planHistoryEntries(plans: planHistory, fallbackPlan: activePlan, calendar: calendar)
        let checkInsByDate = checkInsByDay(checkIns, calendar: calendar)

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
            } else if let committedDays = committedDays(on: dayStart, history: history, calendar: calendar),
                      committedDays.contains(date: dayStart) {
                state = dayStart == today ? .pending : .missed
            } else if dayStart == today {
                state = .pending
            } else {
                state = .restDay
            }

            result.append(WeekDayState(id: i, label: labels[i], state: state))
        }

        return result
    }

    static func weekDayCards(
        checkIns: [CheckInSnapshot],
        now: Date = .now
    ) -> [WeekDayCardData] {
        let calendar = mondayCalendar()
        let today = calendar.startOfDay(for: now)
        guard let monday = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }

        let labels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        let dayNumberFormatter = DateFormatter()
        dayNumberFormatter.dateFormat = "d"

        let checkInsByDate = checkInsByDay(checkIns, calendar: calendar)
        var result: [WeekDayCardData] = []

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: i, to: monday) else { continue }
            let dayStart = calendar.startOfDay(for: day)

            result.append(WeekDayCardData(
                id: i,
                dayLabel: labels[i],
                dateNumber: dayNumberFormatter.string(from: day),
                isToday: dayStart == today,
                checkIn: checkInsByDate[dayStart]
            ))
        }

        return result
    }

    static func adherenceMonths(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        now: Date = .now
    ) -> [AdherenceMonth] {
        let calendar = mondayCalendar()
        let history = planHistoryEntries(plans: planHistory, fallbackPlan: activePlan, calendar: calendar)
        let today = calendar.startOfDay(for: now)
        let firstPlanStart = history.first?.startDate

        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: firstPlanStart ?? today)) ?? today
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        let checkInsByDate = checkInsByDay(checkIns, calendar: calendar)

        var months: [AdherenceMonth] = []
        var cursor = currentMonth

        while cursor >= startMonth {
            months.append(makeAdherenceMonth(
                monthStart: cursor,
                today: today,
                firstPlanStart: firstPlanStart,
                history: history,
                checkInsByDay: checkInsByDate,
                calendar: calendar
            ))

            guard let previous = calendar.date(byAdding: .month, value: -1, to: cursor) else { break }
            cursor = previous
        }

        if months.isEmpty {
            return [makeFallbackMonth(today: today, calendar: calendar)]
        }
        return months
    }

    static func urgeTrend(
        checkIns: [CheckInSnapshot],
        interventions: [UrgeSnapshot],
        now: Date = .now
    ) -> [Double] {
        let calendar = mondayCalendar()
        let today = calendar.startOfDay(for: now)
        let checkInsByDate = checkInsByDay(checkIns, calendar: calendar)

        var interventionCountByDate: [Date: Int] = [:]
        for intervention in interventions {
            let day = calendar.startOfDay(for: intervention.timestamp)
            interventionCountByDate[day, default: 0] += 1
        }

        var values: [Double] = []
        var previousValue = 0.0

        for daysBack in stride(from: 29, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -daysBack, to: today) else { continue }
            let day = calendar.startOfDay(for: date)

            let value: Double
            if let checkIn = checkInsByDate[day] {
                value = Double(checkIn.urgeLevel.rawValue)
            } else if let interventionCount = interventionCountByDate[day], interventionCount > 0 {
                value = min(3.0, 1.0 + Double(interventionCount) * 0.5)
            } else {
                value = previousValue
            }

            values.append(value)
            previousValue = value
        }

        if values.isEmpty {
            return Array(repeating: 0, count: 30)
        }
        return values
    }
}

private extension StatsCalculator {

    static func mondayCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }

    static func planHistoryEntries(
        plans: [PlanSnapshot],
        fallbackPlan: PlanSnapshot?,
        calendar: Calendar
    ) -> [PlanHistoryEntry] {
        let sourcePlans = plans.isEmpty ? (fallbackPlan.map { [$0] } ?? []) : plans
        let sorted = sourcePlans.sorted { $0.createdAt < $1.createdAt }
        var byDay: [Date: PlanHistoryEntry] = [:]

        for plan in sorted {
            let day = calendar.startOfDay(for: plan.createdAt)
            byDay[day] = PlanHistoryEntry(startDate: day, committedDays: plan.days)
        }

        return byDay.values.sorted { $0.startDate < $1.startDate }
    }

    static func committedDays(on date: Date, history: [PlanHistoryEntry], calendar: Calendar) -> DaysOfWeek? {
        let day = calendar.startOfDay(for: date)
        return history.last(where: { $0.startDate <= day })?.committedDays
    }

    static func checkInsByDay(_ checkIns: [CheckInSnapshot], calendar: Calendar) -> [Date: CheckInSnapshot] {
        var dict: [Date: CheckInSnapshot] = [:]
        for checkIn in checkIns.sorted(by: { $0.date < $1.date }) {
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

    static func makeAdherenceMonth(
        monthStart: Date,
        today: Date,
        firstPlanStart: Date?,
        history: [PlanHistoryEntry],
        checkInsByDay: [Date: CheckInSnapshot],
        calendar: Calendar
    ) -> AdherenceMonth {
        let monthId = monthStart.formatted(.dateTime.year().month(.twoDigits))
        let daysRange = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<2
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingPadding = (weekday + 5) % 7
        let displayName = monthStart.formatted(.dateTime.month(.wide).year())

        var cells: [AdherenceDayCell] = []
        var numerator = 0
        var denominator = 0

        for _ in 0..<leadingPadding {
            cells.append(AdherenceDayCell(
                id: "\(monthId)-padding-\(cells.count)",
                date: nil,
                state: .padding
            ))
        }

        for day in daysRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let checkIn = checkInsByDay[dayStart]
            let isFuture = dayStart > today
            let isBeforePlan = firstPlanStart.map { dayStart < $0 } ?? true
            let isToday = calendar.isDate(dayStart, inSameDayAs: today)
            let committedForDay = committedDays(on: dayStart, history: history, calendar: calendar)
            let isCommitted = committedForDay?.contains(date: dayStart) ?? false

            if isCommitted {
                denominator += 1
                if let adherence = checkIn?.planAdherence,
                   checkIn?.wasPlanDay == true,
                   adherence == .yes || adherence == .partially {
                    numerator += 1
                }
            }

            let state: AdherenceCellState
            if isBeforePlan || isFuture {
                state = .inactive
            } else if checkIn == nil && isToday {
                state = .todayNeutral
            } else if let checkIn {
                switch checkIn.planAdherence {
                case .yes, .partially:
                    state = checkIn.wasPlanDay ? .committedFollowed : .offFollowed
                case .no, nil:
                    state = checkIn.wasPlanDay ? .committedMissed : .offNeutral
                }
            } else if isCommitted {
                state = .committedMissed
            } else {
                state = .offNeutral
            }

            cells.append(AdherenceDayCell(
                id: "\(monthId)-day-\(day)",
                date: dayStart,
                state: state
            ))
        }

        while cells.count < 42 {
            cells.append(AdherenceDayCell(
                id: "\(monthId)-padding-\(cells.count)",
                date: nil,
                state: .padding
            ))
        }

        let percentage = denominator > 0 ? Int((Double(numerator) / Double(denominator)) * 100) : 0

        return AdherenceMonth(
            id: monthId,
            displayName: displayName,
            cells: cells,
            numerator: numerator,
            denominator: denominator,
            percentage: percentage
        )
    }

    static func makeFallbackMonth(today: Date, calendar: Calendar) -> AdherenceMonth {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        return makeAdherenceMonth(
            monthStart: monthStart,
            today: today,
            firstPlanStart: nil,
            history: [],
            checkInsByDay: [:],
            calendar: calendar
        )
    }
}
