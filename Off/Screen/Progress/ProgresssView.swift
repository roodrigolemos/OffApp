//
//  ProgresssView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import Charts

struct ProgresssView: View {

    @Environment(AttributeManager.self) var attributeManager
    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager

    @State private var showArchive: Bool = false
    @State private var isUsageExpanded: Bool = false
    @State private var selectedMonthIndex: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        attributeTrendsSection
                        planAdherenceSection
                        urgePatternSection
                        weeklyFeedbackSection
                        checkInHistorySection
                        usageDataSection
                    }
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
    ProgresssView()
        .withPreviewManagers()
}

// MARK: - Sections

private extension ProgresssView {

    var headerSection: some View {
        Text("Progress")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offTextPrimary)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
    }

    var attributeTrendsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("ATTRIBUTE TRENDS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            trendChartsGrid
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var planAdherenceSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PLAN ADHERENCE")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            adherenceCalendarCard
            streakCardsRow
            adherenceInsightCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var urgePatternSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("URGE PATTERNS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            urgePatternCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var weeklyFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("FEEDBACKS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            weeklyFeedbackCard
            if showArchive {
                weeklyFeedbackArchive
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var checkInHistorySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PREVIOUS WEEKS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            previousWeeksStack
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var usageDataSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            usageDataHeader

            if isUsageExpanded {
                usageDataContent
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

// MARK: - Helper Views

private extension ProgresssView {

    var trendChartsGrid: some View {
        let scores = attributeManager.scores

        return LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ], spacing: 14) {
            ForEach(Attribute.allCases, id: \.self) { attribute in
                trendChartCard(
                    attribute: attribute,
                    currentScore: scores?.scores[attribute] ?? 3.0,
                    momentum: scores?.momentum[attribute] ?? false
                )
            }
        }
    }

    func trendChartCard(attribute: Attribute, currentScore: Double, momentum: Bool) -> some View {
        let description = levelDescription(for: attribute, score: currentScore)

        return ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: attribute.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }

                    Spacer()

                    if momentum {
                        Text("Momentum")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(Color.offAccent)
                            .tracking(0.4)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.offAccent.opacity(0.12))
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(attribute.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    HStack(spacing: 4) {
                        scoreDots(score: currentScore)
                    }

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextMuted)
                        .padding(.top, 8)
                }
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var adherenceCalendarCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(spacing: 16) {
                monthNavigationHeader
                adherenceDayLabels
                adherenceGrid
                adherenceStats
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var monthNavigationHeader: some View {
        let monthCount = adherenceMonths.count
        let selected = selectedAdherenceMonth

        return HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedMonthIndex = min(selectedMonthIndex + 1, monthCount - 1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedMonthIndex < monthCount - 1
                        ? Color.offTextPrimary
                        : Color.offTextMuted.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedMonthIndex >= monthCount - 1)

            Spacer()

            Text(selected.displayName.uppercased())
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.4)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedMonthIndex = max(selectedMonthIndex - 1, 0)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedMonthIndex > 0
                        ? Color.offTextPrimary
                        : Color.offTextMuted.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedMonthIndex == 0)
        }
        .padding(.bottom, 12)
    }

    var adherenceDayLabels: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, day in
                Text(day)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offTextMuted)
                    .tracking(1.0)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    var adherenceGrid: some View {
        let monthData = selectedAdherenceMonth.cells
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(monthData) { day in
                if day.state == .padding {
                    Color.clear
                        .frame(width: 28, height: 28)
                } else {
                    Circle()
                        .fill(adherenceFillColor(for: day.state))
                        .overlay {
                            Circle()
                                .stroke(adherenceStrokeColor(for: day.state), lineWidth: adherenceStrokeWidth(for: day.state))
                        }
                        .frame(width: 28, height: 28)
                }
            }
        }
    }

    var adherenceStats: some View {
        let month = selectedAdherenceMonth

        return HStack {
            Text("\(month.numerator)/\(month.denominator) plan days · \(month.percentage)%")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offTextPrimary)
            Spacer()
        }
    }

    var streakCardsRow: some View {
        HStack(spacing: 14) {
            planAdherenceDaysCard
            currentStreakCard
            bestEverStreakCard
        }
    }

    var planAdherenceDaysCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.offAccent.opacity(0.15),
                                        Color.offAccent.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("\(adherenceMetrics.totalDaysFollowed)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)
                }

                Text("Days\nfollowed")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var currentStreakCard: some View {
        let streakInfo = adherenceMetrics

        return ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.offAccent.opacity(0.15),
                                        Color.offAccent.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("\(streakInfo.current)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)
                }

                Text("Current\nstreak")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var bestEverStreakCard: some View {
        let streakInfo = adherenceMetrics

        return ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offTextPrimary.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.offAccent.opacity(0.15),
                                        Color.offAccent.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("\(streakInfo.bestEver)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)
                }

                Text("Best\never")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var adherenceInsightCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.offAccent.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                }

                Text("You follow your plan more on weekdays")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextPrimary)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var urgePatternCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 14) {
                Text("30-Day Urge Trend")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                urgeChart
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var urgeChart: some View {
        let points = urgeData.enumerated().map { ChartPoint(id: $0.offset, value: $0.element) }
        let minPoint = points.min(by: { $0.value < $1.value })!
        let maxPoint = points.max(by: { $0.value < $1.value })!

        return Chart {
            ForEach(points) { point in
                AreaMark(
                    x: .value("Day", point.id),
                    y: .value("Urge", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.offWarn.opacity(0.12),
                            Color.offWarn.opacity(0.03),
                            Color.offWarn.opacity(0.01)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            ForEach(points) { point in
                LineMark(
                    x: .value("Day", point.id),
                    y: .value("Urge", point.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.0, lineCap: .round))
                .foregroundStyle(Color.offWarn)
            }

            PointMark(
                x: .value("Day", minPoint.id),
                y: .value("Urge", minPoint.value)
            )
            .foregroundStyle(Color.offSuccess)
            .symbolSize(60)

            PointMark(
                x: .value("Day", maxPoint.id),
                y: .value("Urge", maxPoint.value)
            )
            .foregroundStyle(Color.offWarn)
            .symbolSize(60)
        }
        .chartYScale(domain: 0...3)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(values: [0, 1, 2, 3]) { value in
                AxisValueLabel {
                    Text(urgeLabel(for: value.as(Int.self) ?? 0))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.offTextMuted.opacity(0.7))
                }
                AxisGridLine()
                    .foregroundStyle(Color.offStroke.opacity(0.15))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
                .cornerRadius(12)
        }
        .padding(.vertical, 8)
        .frame(height: 140)
    }

    var weeklyFeedbackCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.15),
                            Color.clear,
                            Color.offAccent.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.12))
                            .frame(width: 28, height: 28)

                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }

                    Text("THIS WEEK")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.offAccent)
                        .tracking(1.4)
                }

                Text("Calm showed up more than low moments. You're building something real here.")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)
                    .lineSpacing(2)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showArchive.toggle()
                    }
                } label: {
                    Text("View past weeks →")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var weeklyFeedbackArchive: some View {
        VStack(spacing: 12) {
            archiveWeekCard(
                dateRange: "Jan 13 – Jan 19",
                insight: "You started noticing urges earlier — that's awareness growing."
            )
            archiveWeekCard(
                dateRange: "Jan 6 – Jan 12",
                insight: "Focus improved on days you followed the evening plan."
            )
            archiveWeekCard(
                dateRange: "Dec 30 – Jan 5",
                insight: "First full week of check-ins. Consistency is the foundation."
            )
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    func archiveWeekCard(dateRange: String, insight: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 8) {
                Text(dateRange.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offTextMuted)
                    .tracking(1.4)

                Text(insight)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var previousWeeksStack: some View {
        VStack(spacing: 12) {
            previousWeekRow(dateRange: "Jan 13 – Jan 19", checkIns: "5/7 check-ins")
            previousWeekRow(dateRange: "Jan 6 – Jan 12", checkIns: "6/7 check-ins")
            previousWeekRow(dateRange: "Dec 30 – Jan 5", checkIns: "4/7 check-ins")
        }
    }

    func previousWeekRow(dateRange: String, checkIns: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateRange)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(checkIns)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offTextMuted)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var usageDataHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isUsageExpanded.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Text("USAGE DATA")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.offTextMuted)
                    .tracking(1.6)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offTextMuted)
                    .rotationEffect(.degrees(isUsageExpanded ? 180 : 0))
            }
        }
        .buttonStyle(.plain)
    }

    var usageDataContent: some View {
        VStack(spacing: 14) {
            usageTotalCard
            usageBreakdownCard
            usageTrendCard
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    var usageTotalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("2.4h/day")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)

                    Text("average screen time")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.offSuccess)

                    Text("34% from baseline")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offSuccess)
                }
            }
            .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var usageBreakdownCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 14) {
                Text("App Breakdown")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                VStack(spacing: 12) {
                    appRow(icon: "camera.fill", name: "Instagram", time: "1.2h")
                    appRow(icon: "play.rectangle.fill", name: "TikTok", time: "0.8h")
                    appRow(icon: "play.tv.fill", name: "YouTube", time: "0.4h")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var usageTrendCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 14) {
                Text("30-Day Usage Trend")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                usageTrendChart
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var usageTrendChart: some View {
        let points = usageTrendData.enumerated().map { ChartPoint(id: $0.offset, value: $0.element) }
        return Chart {
            ForEach(points) { point in
                BarMark(
                    x: .value("Day", point.id),
                    y: .value("Hours", point.value)
                )
                .foregroundStyle(Color.offAccent.opacity(0.6))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(values: [0, 2, 4]) { _ in
                AxisValueLabel()
            }
        }
        .frame(height: 120)
    }

    func appRow(icon: String, name: String, time: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.offAccent.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.offTextPrimary)

            Spacer()

            Text(time)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offTextSecondary)
        }
    }
}

// MARK: - Helpers

private extension ProgresssView {

    func scoreDots(score: Double) -> some View {
        let normalized = max(1.0, min(5.0, score))
        let fullDots = Int(normalized.rounded(.down))
        let hasHalfDot = (normalized - Double(fullDots)) >= 0.5

        return HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                let fill: Double = if index < fullDots {
                    1.0
                } else if index == fullDots && hasHalfDot {
                    0.5
                } else {
                    0.0
                }

                Circle()
                    .fill(Color.offStroke.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .overlay(alignment: .leading) {
                        Circle()
                            .fill(Color.offAccent)
                            .frame(width: 8, height: 8)
                            .mask(
                                Rectangle()
                                    .frame(width: 8 * fill, height: 8, alignment: .leading)
                            )
                    }
            }
        }
    }

    func levelDescription(for attribute: Attribute, score: Double) -> String {
        let descriptions: [Attribute: [String]] = [
            .clarity: [
                "Overwhelmed, foggy mind",
                "Glimpses of clarity",
                "Noticeably clearer thinking",
                "Clear, focused thinking",
                "Effortless mental clarity"
            ],
            .focus: [
                "Scattered, fleeting attention",
                "Brief focus bursts",
                "Improving sustained attention",
                "Deep concentration ability",
                "Natural flow state"
            ],
            .energy: [
                "Drained, exhausted constantly",
                "Slightly more energy",
                "Stable energy levels",
                "Consistent daily vitality",
                "Energized and present"
            ],
            .drive: [
                "Lost, disconnected",
                "Fleeting direction glimpses",
                "Developing clearer path",
                "Connected to goals",
                "Strong, unwavering purpose"
            ],
            .control: [
                "Powerless against urges",
                "Inconsistent self-control",
                "Growing urge control",
                "Solid impulse management",
                "Full intentional control"
            ],
            .patience: [
                "Zero stillness tolerance",
                "Noticing boredom reactivity",
                "Building stillness tolerance",
                "Comfortable with waiting",
                "Deep inner patience"
            ]
        ]

        let index = Int(max(1.0, min(5.0, score)).rounded(.up)) - 1
        guard let levels = descriptions[attribute], levels.indices.contains(index) else {
            return ""
        }

        return levels[index]
    }

    func urgeLabel(for index: Int) -> String {
        switch index {
        case 0: return "None"
        case 1: return "Notice"
        case 2: return "Persist"
        default: return "Took over"
        }
    }

    var adherenceMetrics: AdherenceStreakMetrics {
        checkInManager.streakMetrics(plan: planManager.activePlan, planHistory: planManager.planHistory)
    }

    var selectedAdherenceMonth: AdherenceMonth {
        let months = adherenceMonths
        let index = min(max(selectedMonthIndex, 0), max(months.count - 1, 0))
        return months[index]
    }

    var adherenceMonths: [AdherenceMonth] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let history = planHistoryEntries(calendar: calendar)
        let today = calendar.startOfDay(for: .now)
        let firstPlanStart = history.first?.startDate

        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: firstPlanStart ?? today)) ?? today
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        let checkInsByDay = Dictionary(uniqueKeysWithValues: checkInManager.checkIns.map { (calendar.startOfDay(for: $0.date), $0) })

        var months: [AdherenceMonth] = []
        var cursor = currentMonth

        while cursor >= startMonth {
            let monthStart = cursor
            let month = makeAdherenceMonth(
                monthStart: monthStart,
                today: today,
                firstPlanStart: firstPlanStart,
                history: history,
                checkInsByDay: checkInsByDay,
                calendar: calendar
            )
            months.append(month)

            guard let previous = calendar.date(byAdding: .month, value: -1, to: monthStart) else { break }
            cursor = previous
        }

        return months.isEmpty ? [makeFallbackMonth(today: today, calendar: calendar)] : months
    }

    func adherenceFillColor(for state: AdherenceCellState) -> Color {
        switch state {
        case .committedFollowed: return Color.offAccent
        case .committedMissed: return Color.offWarn
        case .offFollowed: return Color.offAccent.opacity(0.16)
        case .offNeutral: return Color.offTextMuted.opacity(0.2)
        case .inactive: return Color.offBackgroundPrimary
        case .todayNeutral: return Color.offBackgroundSecondary
        case .padding: return .clear
        }
    }

    func adherenceStrokeColor(for state: AdherenceCellState) -> Color {
        switch state {
        case .offFollowed, .todayNeutral: return Color.offAccent
        case .inactive: return Color.offStroke
        case .padding, .committedFollowed, .committedMissed, .offNeutral: return .clear
        }
    }

    func adherenceStrokeWidth(for state: AdherenceCellState) -> CGFloat {
        switch state {
        case .offFollowed, .todayNeutral: return 1
        default: return 0
        }
    }

    func planHistoryEntries(calendar: Calendar) -> [PlanHistoryEntry] {
        let plans = planManager.planHistory.isEmpty ? (planManager.activePlan.map { [$0] } ?? []) : planManager.planHistory
        let sorted = plans.sorted { $0.createdAt < $1.createdAt }
        var byDay: [Date: PlanHistoryEntry] = [:]

        for plan in sorted {
            let day = calendar.startOfDay(for: plan.createdAt)
            byDay[day] = PlanHistoryEntry(startDate: day, committedDays: plan.days)
        }

        return byDay.values.sorted { $0.startDate < $1.startDate }
    }

    func committedDays(on date: Date, history: [PlanHistoryEntry], calendar: Calendar) -> DaysOfWeek? {
        let day = calendar.startOfDay(for: date)
        return history.last(where: { $0.startDate <= day })?.committedDays
    }

    func makeAdherenceMonth(
        monthStart: Date,
        today: Date,
        firstPlanStart: Date?,
        history: [PlanHistoryEntry],
        checkInsByDay: [Date: CheckInSnapshot],
        calendar: Calendar
    ) -> AdherenceMonth {
        let daysRange = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<2
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingPadding = (weekday + 5) % 7
        let display = monthStart.formatted(.dateTime.month(.wide).year())

        var cells: [AdherenceDayCell] = []
        var numerator = 0
        var denominator = 0

        for _ in 0..<leadingPadding {
            cells.append(AdherenceDayCell(date: nil, state: .padding))
        }

        for day in daysRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let checkIn = checkInsByDay[dayStart]
            let isFuture = dayStart > today
            let isBeforePlan = firstPlanStart.map { dayStart < $0 } ?? true
            let isToday = calendar.isDate(dayStart, inSameDayAs: today)
            let committedForDay = committedDays(on: dayStart, history: history, calendar: calendar)
            let isCommitted = committedForDay?.contains(date: dayStart) ?? false

            if isCommitted {
                denominator += 1
                if let adherence = checkIn?.planAdherence,
                   checkIn?.wasPlanDay == true,
                   adherence == .yes || adherence == .partially {
                    numerator += 1
                }
            }

            let state: AdherenceCellState
            if isBeforePlan || isFuture {
                state = .inactive
            } else if checkIn == nil && isToday {
                state = .todayNeutral
            } else if let checkIn {
                switch checkIn.planAdherence {
                case .yes, .partially:
                    state = checkIn.wasPlanDay ? .committedFollowed : .offFollowed
                case .no, nil:
                    state = checkIn.wasPlanDay ? .committedMissed : .offNeutral
                }
            } else if isCommitted {
                state = .committedMissed
            } else {
                state = .offNeutral
            }

            cells.append(AdherenceDayCell(date: dayStart, state: state))
        }

        while cells.count < 42 {
            cells.append(AdherenceDayCell(date: nil, state: .padding))
        }

        let percentage = denominator > 0 ? Int((Double(numerator) / Double(denominator)) * 100) : 0
        let id = monthStart.formatted(.dateTime.year().month(.twoDigits))
        return AdherenceMonth(
            id: id,
            displayName: display,
            cells: cells,
            numerator: numerator,
            denominator: denominator,
            percentage: percentage
        )
    }

    func makeFallbackMonth(today: Date, calendar: Calendar) -> AdherenceMonth {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        return makeAdherenceMonth(
            monthStart: monthStart,
            today: today,
            firstPlanStart: nil,
            history: [],
            checkInsByDay: [:],
            calendar: calendar
        )
    }

    var urgeData: [Double] {
        [2.8, 2.5, 2.7, 2.9, 2.4, 2.6, 2.3, 2.5, 2.2, 2.4, 2.1, 2.3, 2.0, 2.2, 1.9, 2.1, 1.8, 2.0, 1.7, 1.9, 1.6, 1.8, 1.5, 1.7, 1.4, 1.6, 1.3, 1.5, 1.2, 1.1]
    }

    var usageTrendData: [Double] {
        [4.2, 4.0, 3.8, 4.1, 3.9, 3.7, 3.5, 3.8, 3.6, 3.4, 3.3, 3.5, 3.2, 3.0, 3.3, 3.1, 2.9, 3.0, 2.8, 2.7, 2.9, 2.6, 2.8, 2.5, 2.7, 2.4, 2.6, 2.3, 2.5, 2.4]
    }
}

// MARK: - Private Models

private struct ChartPoint: Identifiable {
    let id: Int
    let value: Double
}

private enum AdherenceCellState: Equatable {
    case padding
    case inactive
    case committedFollowed
    case committedMissed
    case offFollowed
    case offNeutral
    case todayNeutral
}

private struct AdherenceDayCell: Identifiable, Equatable {
    let id = UUID()
    let date: Date?
    let state: AdherenceCellState
}

private struct AdherenceMonth: Identifiable, Equatable {
    let id: String
    let displayName: String
    let cells: [AdherenceDayCell]
    let numerator: Int
    let denominator: Int
    let percentage: Int
}
