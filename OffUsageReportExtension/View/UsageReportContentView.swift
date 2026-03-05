//
//  UsageReportContentView.swift
//  OffUsageReportExtension
//

import SwiftUI
import Charts

struct UsageReportContentView: View {

    let configuration: UsageReportConfiguration
    @State private var selectedPeriod: UsageDashboardPeriod = .sevenDays

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection
                heroSection
                trendSection
                signalsSection
                breakdownSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
        .scrollIndicators(.hidden)
        .background(Color.offBackgroundPrimaryTone)
    }
}

private extension UsageReportContentView {

    var headerSection: some View {
        Text("Usage")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offPrimaryText)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
    }

    var heroSection: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TODAY PULSE")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.offMutedText)
                        .tracking(1.1)
                    Spacer()
                    if configuration.trend.hasAnyTrackedUsage,
                       let delta = configuration.hero.todayVersusSevenDayAverageDelta {
                        Text("vs avg \(UsageFormatters.percentDeltaText(from: delta))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(delta <= 0 ? Color.offSuccessTone : Color.offWarningTone)
                    }
                }

                if configuration.trend.hasAnyTrackedUsage {
                    Text(UsageFormatters.durationText(from: configuration.hero.todayTotalDurationSeconds))
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(Color.offPrimaryText)

                    VStack(alignment: .leading, spacing: 6) {
                        if let checks = configuration.hero.todayChecksCount {
                            Text("\(checks) checks today")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.offSecondaryText)
                        }
                        if let topApp = configuration.hero.todayTopAppName {
                            Text("Top app: \(topApp)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.offSecondaryText)
                                .lineLimit(1)
                        }
                    }
                } else {
                    Text("Waiting for usage data")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(Color.offPrimaryText)

                    Text("Data can take a little time after enabling tracking.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var trendSection: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text("RECOVERY TREND")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.offMutedText)
                        .tracking(1.1)
                    Spacer()
                    Picker("Period", selection: $selectedPeriod) {
                        Text("7 days").tag(UsageDashboardPeriod.sevenDays)
                        Text("30 days").tag(UsageDashboardPeriod.thirtyDays)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 172)
                }

                if currentDayTotals.contains(where: { $0.totalDurationSeconds > 0 }) {
                    Chart {
                        ForEach(currentDayTotals) { day in
                            AreaMark(
                                x: .value("Day", day.date),
                                y: .value("Duration", day.totalDurationSeconds / 3600.0)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.offAccentTone.opacity(0.22),
                                        Color.offAccentSoftTone.opacity(0.10)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            LineMark(
                                x: .value("Day", day.date),
                                y: .value("Duration", day.totalDurationSeconds / 3600.0)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(Color.offAccentTone)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 148)
                } else {
                    emptyStateText(emptyTrendText)
                }

                Text(trendContextLine)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offSecondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var signalsSection: some View {
        let signals = currentSignals
        let hasTrackedUsage = configuration.trend.hasAnyTrackedUsage

        return UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("RECOVERY SIGNALS")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offMutedText)
                    .tracking(1.1)

                HStack(spacing: 10) {
                    signalTile(
                        label: "Avg/day",
                        value: hasTrackedUsage ? UsageFormatters.durationText(from: signals.averagePerDaySeconds) : "—"
                    )
                    signalTile(
                        label: "Active days",
                        value: hasTrackedUsage ? "\(signals.activeDayCount)" : "—"
                    )
                    signalTile(
                        label: "Peak day",
                        value: hasTrackedUsage ? peakValueText(from: signals) : "—"
                    )
                }

                if hasTrackedUsage, let checks = signals.totalChecksCount {
                    Text("\(checks) checks in this period")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                } else if !hasTrackedUsage {
                    Text("Usage signals will appear once tracking data arrives.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var breakdownSection: some View {
        UsageAppBreakdownSectionView(
            selectedPeriod: $selectedPeriod,
            breakdown: configuration.breakdown,
            hasAnyTrackedUsage: configuration.trend.hasAnyTrackedUsage
        )
    }

    var currentDayTotals: [UsageDayTotalSnapshot] {
        switch selectedPeriod {
        case .sevenDays:
            configuration.trend.sevenDayTotals
        case .thirtyDays:
            configuration.trend.thirtyDayTotals
        }
    }

    var currentSignals: UsagePeriodSignalsSnapshot {
        switch selectedPeriod {
        case .sevenDays:
            configuration.signals.sevenDay
        case .thirtyDays:
            configuration.signals.thirtyDay
        }
    }

    var trendContextLine: String {
        guard configuration.trend.hasAnyTrackedUsage else {
            return "Tracking is enabled. Data may take time to populate."
        }

        switch selectedPeriod {
        case .sevenDays:
            if let delta = configuration.trend.sevenVersusPreviousSevenDelta {
                return "Last 7 vs previous 7: \(UsageFormatters.percentDeltaText(from: delta))"
            }
            return "Not enough previous-week data yet"
        case .thirtyDays:
            return "30-day average: \(UsageFormatters.durationText(from: configuration.trend.thirtyDayAverageSeconds))"
        }
    }

    var emptyTrendText: String {
        if configuration.trend.hasAnyTrackedUsage {
            return "No tracked activity yet for this period."
        }
        return "No tracked usage yet. Data can take some time after setup."
    }

    func signalTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(Color.offMutedText)
                .tracking(0.9)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.offPrimaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.offTileBackground)
        )
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentTone.opacity(0.04),
                            Color.offAccentSoftTone.opacity(0.40)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.offTileStroke, lineWidth: 1)
        )
    }

    func peakValueText(from signals: UsagePeriodSignalsSnapshot) -> String {
        guard let label = signals.peakDayLabel else { return "None" }
        return label
    }

    func emptyStateText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.offSecondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}

private struct UsageAppBreakdownSectionView: View {

    @Binding var selectedPeriod: UsageDashboardPeriod
    let breakdown: UsageBreakdownSnapshot
    let hasAnyTrackedUsage: Bool
    @State private var isExpanded: Bool = false

    var body: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("WHAT PULLED YOU IN")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offMutedText)
                    .tracking(1.1)

                if currentApps.isEmpty {
                    Text(hasAnyTrackedUsage ? "No app-level usage available yet." : "No tracked app activity yet.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                } else {
                    VStack(spacing: 10) {
                        ForEach(visibleApps) { app in
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Text(app.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.offPrimaryText)
                                        .lineLimit(1)

                                    Spacer()

                                    Text(UsageFormatters.durationText(from: app.totalDurationSeconds))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.offSecondaryText)
                                }

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.offTrackBackground)

                                        Capsule()
                                            .fill(Color.offAccentTone.opacity(0.8))
                                            .frame(width: max(2, geometry.size.width * app.share))
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                    }
                }

                if currentApps.count > collapsedCount {
                    Button(isExpanded ? "Show less" : "Show more") {
                        isExpanded.toggle()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offAccentTone)
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: selectedPeriod) {
            isExpanded = false
        }
    }
}

private extension UsageAppBreakdownSectionView {

    var collapsedCount: Int { 5 }

    var currentApps: [UsageAppBreakdownSnapshot] {
        switch selectedPeriod {
        case .sevenDays:
            breakdown.sevenDayApps
        case .thirtyDays:
            breakdown.thirtyDayApps
        }
    }

    var visibleApps: [UsageAppBreakdownSnapshot] {
        if isExpanded { return currentApps }
        return Array(currentApps.prefix(collapsedCount))
    }
}

private enum UsageDashboardPeriod: Hashable {
    case sevenDays
    case thirtyDays
}

private extension Color {
    static let offBackgroundPrimaryTone = Color(
        red: 246.0 / 255.0,
        green: 244.0 / 255.0,
        blue: 239.0 / 255.0
    )
    static let offBackgroundSecondaryTone = Color.white
    static let offPrimaryText = Color(red: 0.11, green: 0.13, blue: 0.16)
    static let offSecondaryText = Color(red: 0.38, green: 0.42, blue: 0.47)
    static let offMutedText = Color(red: 0.49, green: 0.53, blue: 0.58)
    static let offAccentTone = Color(
        red: 76.0 / 255.0,
        green: 122.0 / 255.0,
        blue: 138.0 / 255.0
    )
    static let offAccentSoftTone = Color(
        red: 230.0 / 255.0,
        green: 240.0 / 255.0,
        blue: 243.0 / 255.0
    )
    static let offSuccessTone = Color(red: 0.18, green: 0.64, blue: 0.38)
    static let offWarningTone = Color(red: 0.83, green: 0.54, blue: 0.16)
    static let offTileBackground = Color.offBackgroundSecondaryTone
    static let offTileStroke = Color(
        red: 230.0 / 255.0,
        green: 225.0 / 255.0,
        blue: 217.0 / 255.0
    )
    static let offTrackBackground = Color.offAccentSoftTone
}
