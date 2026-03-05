//
//  UsageReportManager.swift
//  OffUsageReportExtension
//

import Foundation
import Observation
import DeviceActivity
import _DeviceActivity_SwiftUI

enum UsageReportError: Error, LocalizedError {
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Could not load usage report data."
        }
    }
}

@MainActor
@Observable
final class UsageReportManager {

    private let store: UsageReportStore

    var error: UsageReportError?

    init(store: UsageReportStore) {
        self.store = store
    }

    func makeConfiguration(
        from data: DeviceActivityResults<DeviceActivityData>,
        now: Date = .now
    ) async -> UsageReportConfiguration {
        do {
            let raw = try await store.loadRawSnapshot(from: data)
            error = nil
            return buildConfiguration(from: raw, now: now)
        } catch {
            self.error = .loadFailed
            return UsageReportConfiguration.empty
        }
    }
}

private extension UsageReportManager {

    func buildConfiguration(from raw: UsageReportRawSnapshot, now: Date) -> UsageReportConfiguration {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let thirtyDayDates = rollingDates(
            endingAt: today,
            dayCount: 30,
            calendar: calendar
        )

        let sevenDayDates = Array(thirtyDayDates.suffix(7))
        let previousSevenDayDates = Array(thirtyDayDates.dropLast(7).suffix(7))

        let todayDurations = raw.dailyAppDurations[today] ?? [:]
        let topAppToday = todayDurations.max(by: { $0.value < $1.value })?.key

        let todaySnapshot = UsageTodaySnapshot(
            totalDurationSeconds: raw.dailyDurations[today, default: 0],
            checksCount: raw.hasApplicationUsage ? raw.dailyChecks[today, default: 0] : nil,
            topAppName: topAppToday
        )

        let topApps = topApps(for: sevenDayDates, dailyAppDurations: raw.dailyAppDurations)
        let sevenDayTotal = totalDuration(for: sevenDayDates, dailyDurations: raw.dailyDurations)
        let sevenDayAverage = sevenDayTotal / 7.0
        let peakDay = peakDayInfo(for: sevenDayDates, dailyDurations: raw.dailyDurations)

        let lastSevenSnapshot = UsageLastSevenDaysSnapshot(
            topApps: topApps,
            averagePerDaySeconds: sevenDayAverage,
            totalChecksCount: raw.hasApplicationUsage ? totalChecks(for: sevenDayDates, dailyChecks: raw.dailyChecks) : nil,
            peakDayLabel: peakDay?.label,
            peakDayDurationSeconds: peakDay?.duration
        )

        let dayTotals = thirtyDayDates.map { date in
            UsageDayTotalSnapshot(
                id: date,
                date: date,
                totalDurationSeconds: raw.dailyDurations[date, default: 0]
            )
        }

        let previousSevenTotal = totalDuration(for: previousSevenDayDates, dailyDurations: raw.dailyDurations)
        let contextLine: String
        if previousSevenTotal > 0 {
            let delta = (sevenDayTotal - previousSevenTotal) / previousSevenTotal
            contextLine = "Last 7 vs previous 7: \(UsageFormatters.percentDeltaText(from: delta))"
        } else {
            let averageThirty = dayTotals.reduce(0) { $0 + $1.totalDurationSeconds } / 30.0
            contextLine = "30-day average: \(UsageFormatters.durationText(from: averageThirty))"
        }

        let lastThirtySnapshot = UsageLastThirtyDaysSnapshot(
            dayTotals: dayTotals,
            contextLine: contextLine
        )

        return UsageReportConfiguration(
            today: todaySnapshot,
            lastSevenDays: lastSevenSnapshot,
            lastThirtyDays: lastThirtySnapshot
        )
    }

    func rollingDates(endingAt end: Date, dayCount: Int, calendar: Calendar) -> [Date] {
        guard dayCount > 0 else { return [] }
        let start = calendar.date(byAdding: .day, value: -(dayCount - 1), to: end) ?? end
        return (0..<dayCount).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start)
        }
    }

    func topApps(
        for days: [Date],
        dailyAppDurations: [Date: [String: TimeInterval]]
    ) -> [UsageAppUsageSnapshot] {
        var totals: [String: TimeInterval] = [:]

        for day in days {
            for (name, duration) in dailyAppDurations[day] ?? [:] {
                totals[name, default: 0] += duration
            }
        }

        return totals
            .sorted { lhs, rhs in lhs.value > rhs.value }
            .prefix(5)
            .map { item in
                UsageAppUsageSnapshot(id: item.key, name: item.key, totalDurationSeconds: item.value)
            }
    }

    func totalDuration(for days: [Date], dailyDurations: [Date: TimeInterval]) -> TimeInterval {
        days.reduce(0) { partialResult, day in
            partialResult + dailyDurations[day, default: 0]
        }
    }

    func totalChecks(for days: [Date], dailyChecks: [Date: Int]) -> Int {
        days.reduce(0) { partialResult, day in
            partialResult + dailyChecks[day, default: 0]
        }
    }

    func peakDayInfo(
        for days: [Date],
        dailyDurations: [Date: TimeInterval]
    ) -> (label: String, duration: TimeInterval)? {
        guard
            let peak = days.max(by: { dailyDurations[$0, default: 0] < dailyDurations[$1, default: 0] }),
            dailyDurations[peak, default: 0] > 0
        else {
            return nil
        }

        return (
            label: UsageFormatters.weekdayLabel(for: peak),
            duration: dailyDurations[peak, default: 0]
        )
    }
}
