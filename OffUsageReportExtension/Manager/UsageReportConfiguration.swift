//
//  UsageReportConfiguration.swift
//  OffUsageReportExtension
//

import Foundation

struct UsageReportConfiguration {
    let today: UsageTodaySnapshot
    let lastSevenDays: UsageLastSevenDaysSnapshot
    let lastThirtyDays: UsageLastThirtyDaysSnapshot
}

struct UsageTodaySnapshot {
    let totalDurationSeconds: TimeInterval
    let checksCount: Int?
    let topAppName: String?
}

struct UsageLastSevenDaysSnapshot {
    let topApps: [UsageAppUsageSnapshot]
    let averagePerDaySeconds: TimeInterval
    let totalChecksCount: Int?
    let peakDayLabel: String?
    let peakDayDurationSeconds: TimeInterval?
}

struct UsageLastThirtyDaysSnapshot {
    let dayTotals: [UsageDayTotalSnapshot]
    let contextLine: String
}

struct UsageAppUsageSnapshot: Identifiable {
    let id: String
    let name: String
    let totalDurationSeconds: TimeInterval
}

struct UsageDayTotalSnapshot: Identifiable {
    let id: Date
    let date: Date
    let totalDurationSeconds: TimeInterval
}

extension UsageReportConfiguration {
    static let empty = UsageReportConfiguration(
        today: UsageTodaySnapshot(totalDurationSeconds: 0, checksCount: nil, topAppName: nil),
        lastSevenDays: UsageLastSevenDaysSnapshot(
            topApps: [],
            averagePerDaySeconds: 0,
            totalChecksCount: nil,
            peakDayLabel: nil,
            peakDayDurationSeconds: nil
        ),
        lastThirtyDays: UsageLastThirtyDaysSnapshot(dayTotals: [], contextLine: "30-day average: 0m")
    )
}
