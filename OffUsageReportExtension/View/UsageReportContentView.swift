//
//  UsageReportContentView.swift
//  OffUsageReportExtension
//

import SwiftUI

struct UsageReportContentView: View {

    let configuration: UsageReportConfiguration

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                UsageTodayCardView(snapshot: configuration.today)
                UsageLastSevenDaysCardView(snapshot: configuration.lastSevenDays)
                UsageLastThirtyDaysCardView(snapshot: configuration.lastThirtyDays)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(white: 0.97))
    }
}
