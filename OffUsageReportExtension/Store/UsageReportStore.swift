//
//  UsageReportStore.swift
//  OffUsageReportExtension
//

import DeviceActivity
import Foundation
import ManagedSettings
import _DeviceActivity_SwiftUI

struct UsageReportRawSnapshot {
    let dailyDurations: [Date: TimeInterval]
    let dailyChecks: [Date: Int]
    let dailyAppDurations: [Date: [String: TimeInterval]]
    let hasApplicationUsage: Bool
}

@MainActor
protocol UsageReportStore {
    func loadRawSnapshot(from data: DeviceActivityResults<DeviceActivityData>) async throws -> UsageReportRawSnapshot
}

@MainActor
final class DeviceActivityUsageReportStore: UsageReportStore {

    func loadRawSnapshot(from data: DeviceActivityResults<DeviceActivityData>) async throws -> UsageReportRawSnapshot {
        let calendar = Calendar.current

        var dailyDurations: [Date: TimeInterval] = [:]
        var dailyChecks: [Date: Int] = [:]
        var dailyAppDurations: [Date: [String: TimeInterval]] = [:]
        var hasApplicationUsage = false

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                let day = calendar.startOfDay(for: segment.dateInterval.start)
                var dayDuration: TimeInterval = 0
                var dayChecks: Int = 0
                var dayBreakdown = dailyAppDurations[day, default: [:]]

                for await category in segment.categories {
                    for await application in category.applications {
                        hasApplicationUsage = true

                        let appName = appLabel(for: application.application)
                        let appDuration = application.totalActivityDuration
                        dayDuration += appDuration
                        dayChecks += application.numberOfPickups
                        dayBreakdown[appName, default: 0] += appDuration
                    }
                }

                dailyDurations[day, default: 0] += dayDuration
                dailyChecks[day, default: 0] += dayChecks
                if !dayBreakdown.isEmpty {
                    dailyAppDurations[day] = dayBreakdown
                }
            }
        }

        return UsageReportRawSnapshot(
            dailyDurations: dailyDurations,
            dailyChecks: dailyChecks,
            dailyAppDurations: dailyAppDurations,
            hasApplicationUsage: hasApplicationUsage
        )
    }
}

private extension DeviceActivityUsageReportStore {

    func appLabel(for application: Application) -> String {
        application.localizedDisplayName ?? application.bundleIdentifier ?? "App"
    }
}
