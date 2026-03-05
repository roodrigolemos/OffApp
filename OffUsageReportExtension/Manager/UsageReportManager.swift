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

        let todayTotal = raw.dailyDurations[today, default: 0]
        let sevenDayTotal = totalDuration(for: sevenDayDates, dailyDurations: raw.dailyDurations)
        let sevenDayAverage = sevenDayTotal / 7.0
        let thirtyDayTotal = totalDuration(for: thirtyDayDates, dailyDurations: raw.dailyDurations)
        let thirtyDayAverage = thirtyDayTotal / 30.0
        let previousSevenTotal = totalDuration(for: previousSevenDayDates, dailyDurations: raw.dailyDurations)

        let topAppToday = raw.dailyAppDurations[today]?.max(by: { $0.value < $1.value })?.key
        let todayDelta = sevenDayAverage > 0 ? (todayTotal - sevenDayAverage) / sevenDayAverage : nil
        let sevenVersusPrevious = previousSevenTotal > 0
            ? (sevenDayTotal - previousSevenTotal) / previousSevenTotal
            : nil

        let hero = UsageHeroSnapshot(
            todayTotalDurationSeconds: todayTotal,
            todayChecksCount: raw.hasApplicationUsage ? raw.dailyChecks[today, default: 0] : nil,
            todayTopAppName: topAppToday,
            todayVersusSevenDayAverageDelta: todayDelta
        )

        let sevenDayTotals = dayTotals(for: sevenDayDates, dailyDurations: raw.dailyDurations)
        let thirtyDayTotals = dayTotals(for: thirtyDayDates, dailyDurations: raw.dailyDurations)
        let hasAnyTrackedUsage = (sevenDayTotals + thirtyDayTotals).contains { $0.totalDurationSeconds > 0 }

        let trend = UsageTrendSnapshot(
            sevenDayTotals: sevenDayTotals,
            thirtyDayTotals: thirtyDayTotals,
            sevenVersusPreviousSevenDelta: sevenVersusPrevious,
            thirtyDayAverageSeconds: thirtyDayAverage,
            hasAnyTrackedUsage: hasAnyTrackedUsage
        )

        let signals = UsageSignalsSnapshot(
            sevenDay: periodSignals(
                for: sevenDayDates,
                dailyDurations: raw.dailyDurations,
                dailyChecks: raw.dailyChecks,
                hasApplicationUsage: raw.hasApplicationUsage
            ),
            thirtyDay: periodSignals(
                for: thirtyDayDates,
                dailyDurations: raw.dailyDurations,
                dailyChecks: raw.dailyChecks,
                hasApplicationUsage: raw.hasApplicationUsage
            )
        )

        let breakdown = UsageBreakdownSnapshot(
            sevenDayApps: appBreakdown(
                for: sevenDayDates,
                dailyAppDurations: raw.dailyAppDurations,
                dailyDurations: raw.dailyDurations
            ),
            thirtyDayApps: appBreakdown(
                for: thirtyDayDates,
                dailyAppDurations: raw.dailyAppDurations,
                dailyDurations: raw.dailyDurations
            )
        )

        return UsageReportConfiguration(
            hero: hero,
            trend: trend,
            signals: signals,
            breakdown: breakdown
        )
    }

    func rollingDates(endingAt end: Date, dayCount: Int, calendar: Calendar) -> [Date] {
        guard dayCount > 0 else { return [] }
        let start = calendar.date(byAdding: .day, value: -(dayCount - 1), to: end) ?? end
        return (0..<dayCount).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start)
        }
    }

    func appBreakdown(
        for days: [Date],
        dailyAppDurations: [Date: [String: TimeInterval]],
        dailyDurations: [Date: TimeInterval]
    ) -> [UsageAppBreakdownSnapshot] {
        var totals: [String: TimeInterval] = [:]
        let totalDurationInPeriod = totalDuration(for: days, dailyDurations: dailyDurations)

        for day in days {
            for (name, duration) in dailyAppDurations[day] ?? [:] {
                totals[name, default: 0] += duration
            }
        }

        return totals
            .sorted { lhs, rhs in lhs.value > rhs.value }
            .prefix(10)
            .map { item in
                UsageAppBreakdownSnapshot(
                    id: item.key,
                    name: item.key,
                    totalDurationSeconds: item.value,
                    share: totalDurationInPeriod > 0 ? item.value / totalDurationInPeriod : 0
                )
            }
    }

    func dayTotals(
        for days: [Date],
        dailyDurations: [Date: TimeInterval]
    ) -> [UsageDayTotalSnapshot] {
        days.map { day in
            UsageDayTotalSnapshot(
                id: day,
                date: day,
                totalDurationSeconds: dailyDurations[day, default: 0]
            )
        }
    }

    func periodSignals(
        for days: [Date],
        dailyDurations: [Date: TimeInterval],
        dailyChecks: [Date: Int],
        hasApplicationUsage: Bool
    ) -> UsagePeriodSignalsSnapshot {
        let total = totalDuration(for: days, dailyDurations: dailyDurations)
        let average = days.isEmpty ? 0 : total / Double(days.count)
        let activeDays = days.filter { dailyDurations[$0, default: 0] > 0 }.count
        let peak = peakDayInfo(for: days, dailyDurations: dailyDurations)

        return UsagePeriodSignalsSnapshot(
            averagePerDaySeconds: average,
            activeDayCount: activeDays,
            peakDayLabel: peak?.label,
            peakDayDurationSeconds: peak?.duration,
            totalChecksCount: hasApplicationUsage ? totalChecks(for: days, dailyChecks: dailyChecks) : nil
        )
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
