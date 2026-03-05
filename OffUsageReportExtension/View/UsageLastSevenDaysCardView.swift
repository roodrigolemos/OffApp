//
//  UsageLastSevenDaysCardView.swift
//  OffUsageReportExtension
//

import SwiftUI

struct UsageLastSevenDaysCardView: View {

    let snapshot: UsageLastSevenDaysSnapshot

    var body: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Last 7 days")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                Text("What pulled you in")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                if snapshot.topApps.isEmpty {
                    Text("No app activity yet")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 8) {
                        ForEach(snapshot.topApps) { app in
                            HStack {
                                Text(app.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                Spacer()

                                Text(UsageFormatters.durationText(from: app.totalDurationSeconds))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Text(footerText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)

                if let peakDayLabel = snapshot.peakDayLabel,
                   let peakDuration = snapshot.peakDayDurationSeconds {
                    Text("Peak day: \(peakDayLabel) (\(UsageFormatters.durationText(from: peakDuration)))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension UsageLastSevenDaysCardView {

    var footerText: String {
        let averageText = "Avg: \(UsageFormatters.durationText(from: snapshot.averagePerDaySeconds))/day"
        if let totalChecks = snapshot.totalChecksCount {
            return "\(averageText) • \(totalChecks) checks"
        }
        return averageText
    }
}
