//
//  UsageLastThirtyDaysCardView.swift
//  OffUsageReportExtension
//

import SwiftUI
import Charts

struct UsageLastThirtyDaysCardView: View {

    let snapshot: UsageLastThirtyDaysSnapshot

    var body: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Last 30 days")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Your recovery trend")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                Chart {
                    ForEach(snapshot.dayTotals) { day in
                        BarMark(
                            x: .value("Day", day.date),
                            y: .value("Duration", day.totalDurationSeconds / 3600.0)
                        )
                        .foregroundStyle(Color.accentColor.opacity(0.75))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 120)

                Text(snapshot.contextLine)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
