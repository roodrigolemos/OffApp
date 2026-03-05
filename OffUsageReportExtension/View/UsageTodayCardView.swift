//
//  UsageTodayCardView.swift
//  OffUsageReportExtension
//

import SwiftUI

struct UsageTodayCardView: View {

    let snapshot: UsageTodaySnapshot

    var body: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                Text("On selected apps")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(UsageFormatters.durationText(from: snapshot.totalDurationSeconds))
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(.primary)

                if let checksCount = snapshot.checksCount {
                    Text("\(checksCount) checks")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                if let topAppName = snapshot.topAppName {
                    Text("Top app: \(topAppName)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
