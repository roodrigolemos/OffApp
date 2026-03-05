//
//  UsageReportView.swift
//  Off
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct UsageReportView: View {

    @Environment(ScreenTimeManager.self) var screenTimeManager

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            DeviceActivityReport(.usageReport, filter: usageFilter)
            .id(screenTimeManager.selectionDigest)
        }
        .navigationTitle("Usage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension UsageReportView {

    var usageFilter: DeviceActivityFilter {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        let interval = DateInterval(start: start, end: .now)

        return DeviceActivityFilter(
            segment: .daily(during: interval),
            applications: screenTimeManager.activitySelection.applicationTokens,
            categories: screenTimeManager.activitySelection.categoryTokens,
            webDomains: screenTimeManager.activitySelection.webDomainTokens
        )
    }
}

#Preview {
    NavigationStack {
        UsageReportView()
    }
    .withPreviewManagers()
}
