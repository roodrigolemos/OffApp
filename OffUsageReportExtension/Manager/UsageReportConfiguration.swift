//
//  UsageReportConfiguration.swift
//  OffUsageReportExtension
//

import Foundation

struct UsageReportConfiguration {
    let hero: UsageHeroSnapshot
    let trend: UsageTrendSnapshot
    let signals: UsageSignalsSnapshot
    let breakdown: UsageBreakdownSnapshot
}

struct UsageHeroSnapshot {
    let todayTotalDurationSeconds: TimeInterval
    let todayChecksCount: Int?
    let todayTopAppName: String?
    let todayVersusSevenDayAverageDelta: Double?
}

struct UsageTrendSnapshot {
    let sevenDayTotals: [UsageDayTotalSnapshot]
    let thirtyDayTotals: [UsageDayTotalSnapshot]
    let sevenVersusPreviousSevenDelta: Double?
    let thirtyDayAverageSeconds: TimeInterval
    let hasAnyTrackedUsage: Bool
}

struct UsageSignalsSnapshot {
    let sevenDay: UsagePeriodSignalsSnapshot
    let thirtyDay: UsagePeriodSignalsSnapshot
}

struct UsagePeriodSignalsSnapshot {
    let averagePerDaySeconds: TimeInterval
    let activeDayCount: Int
    let peakDayLabel: String?
    let peakDayDurationSeconds: TimeInterval?
    let totalChecksCount: Int?
}

struct UsageBreakdownSnapshot {
    let sevenDayApps: [UsageAppBreakdownSnapshot]
    let thirtyDayApps: [UsageAppBreakdownSnapshot]
}

struct UsageAppBreakdownSnapshot: Identifiable {
    let id: String
    let name: String
    let totalDurationSeconds: TimeInterval
    let share: Double
}

struct UsageDayTotalSnapshot: Identifiable {
    let id: Date
    let date: Date
    let totalDurationSeconds: TimeInterval
}

extension UsageReportConfiguration {
    static let empty = UsageReportConfiguration(
        hero: UsageHeroSnapshot(
            todayTotalDurationSeconds: 0,
            todayChecksCount: nil,
            todayTopAppName: nil,
            todayVersusSevenDayAverageDelta: nil
        ),
        trend: UsageTrendSnapshot(
            sevenDayTotals: [],
            thirtyDayTotals: [],
            sevenVersusPreviousSevenDelta: nil,
            thirtyDayAverageSeconds: 0,
            hasAnyTrackedUsage: false
        ),
        signals: UsageSignalsSnapshot(
            sevenDay: UsagePeriodSignalsSnapshot(
                averagePerDaySeconds: 0,
                activeDayCount: 0,
                peakDayLabel: nil,
                peakDayDurationSeconds: nil,
                totalChecksCount: nil
            ),
            thirtyDay: UsagePeriodSignalsSnapshot(
                averagePerDaySeconds: 0,
                activeDayCount: 0,
                peakDayLabel: nil,
                peakDayDurationSeconds: nil,
                totalChecksCount: nil
            )
        ),
        breakdown: UsageBreakdownSnapshot(
            sevenDayApps: [],
            thirtyDayApps: []
        )
    )
}
