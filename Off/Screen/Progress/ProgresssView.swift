//
//  ProgresssView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import Charts

struct ProgresssView: View {

    @State private var showArchive: Bool = false
    @State private var isUsageExpanded: Bool = false
    @State private var selectedMonthIndex: Int = 0

    var body: some View {
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

#Preview {
    ProgresssView()
}

// MARK: - Sections

private extension ProgresssView {

    // MARK: - Header

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

    // MARK: - Attribute Trends

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

    var trendChartsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ], spacing: 14) {
            trendChartCard(icon: "brain", name: "Clarity", currentScore: 4, delta: "+2")
            trendChartCard(icon: "scope", name: "Focus", currentScore: 4, delta: "+1")
            trendChartCard(icon: "bolt.fill", name: "Energy", currentScore: 4, delta: "+2")
            trendChartCard(icon: "flag.fill", name: "Purpose", currentScore: 4, delta: "+1")
            trendChartCard(icon: "hand.raised.fill", name: "Control", currentScore: 2, delta: "-1")
            trendChartCard(icon: "hourglass", name: "Patience", currentScore: 4, delta: "+1")
        }
    }

    func trendChartCard(icon: String, name: String, currentScore: Int, delta: String) -> some View {
        let description = levelDescription(for: name, score: currentScore)

        return ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }

                    Spacer()

                    trendArrow(for: delta)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index < currentScore ? Color.offAccent : Color.offStroke.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
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

    func trendArrow(for delta: String) -> some View {
        let isPositive = delta.hasPrefix("+")
        let isNeutral = delta.hasPrefix("0") || delta == "0"

        return Image(systemName: isNeutral ? "arrow.right" : (isPositive ? "arrow.up.right" : "arrow.down.right"))
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(isNeutral ? Color.offTextMuted : (isPositive ? Color.offSuccess : Color.offWarn))
    }

    // MARK: - Plan Adherence

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
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedMonthIndex = min(selectedMonthIndex + 1, availableMonths.count - 1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedMonthIndex < availableMonths.count - 1
                        ? Color.offTextPrimary
                        : Color.offTextMuted.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedMonthIndex >= availableMonths.count - 1)

            Spacer()

            Text(availableMonths[selectedMonthIndex].displayName.uppercased())
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
        let monthData = availableMonths[selectedMonthIndex].adherenceData
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(monthData.indices, id: \.self) { index in
                Circle()
                    .fill(adherenceColor(for: monthData[index]))
                    .frame(width: 28, height: 28)
            }
        }
    }

    var adherenceStats: some View {
        let stats = calculateAdherenceStats(monthData: availableMonths[selectedMonthIndex].adherenceData)

        return HStack(spacing: 16) {
            HStack(spacing: 6) {
                Text("\(stats.followedDays)/\(stats.totalDays)")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)
                Text("days")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("\(stats.percentage)%")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color.offAccent)
                Text("adherence")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
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

                    Text("\(calculateTotalDaysFollowed())")
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
        let streakInfo = calculateStreakInfo()

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

                    Text("\(streakInfo.currentStreak)")
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
        let streakInfo = calculateStreakInfo()

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

                    Text("\(streakInfo.bestAllTime)")
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

    // MARK: - Urge Patterns

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

    // MARK: - Weekly Feedback

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

    // MARK: - Check-in History (Previous Weeks)

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

    // MARK: - Usage Data

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

// MARK: - Helper Functions

private extension ProgresssView {

    func levelDescription(for attribute: String, score: Int) -> String {
        let descriptions: [String: [String]] = [
            "Clarity": [
                "Overwhelmed, foggy mind",
                "Glimpses of clarity",
                "Noticeably clearer thinking",
                "Clear, focused thinking",
                "Effortless mental clarity"
            ],
            "Focus": [
                "Scattered, fleeting attention",
                "Brief focus bursts",
                "Improving sustained attention",
                "Deep concentration ability",
                "Natural flow state"
            ],
            "Energy": [
                "Drained, exhausted constantly",
                "Slightly more energy",
                "Stable energy levels",
                "Consistent daily vitality",
                "Energized and present"
            ],
            "Purpose": [
                "Lost, disconnected",
                "Fleeting direction glimpses",
                "Developing clearer path",
                "Connected to goals",
                "Strong, unwavering purpose"
            ],
            "Control": [
                "Powerless against urges",
                "Inconsistent self-control",
                "Growing urge control",
                "Solid impulse management",
                "Full intentional control"
            ],
            "Patience": [
                "Zero stillness tolerance",
                "Noticing boredom reactivity",
                "Building stillness tolerance",
                "Comfortable with waiting",
                "Deep inner patience"
            ]
        ]

        guard let levels = descriptions[attribute], score >= 1 && score <= 5 else {
            return ""
        }

        return levels[score - 1]
    }

    func adherenceColor(for status: Int) -> Color {
        switch status {
        case 1: return Color.offAccent
        case 2: return Color.offAccent.opacity(0.4)
        case 3: return Color.offStroke
        default: return Color.offTextMuted.opacity(0.2)
        }
    }

    func urgeLabel(for index: Int) -> String {
        switch index {
        case 0: return "None"
        case 1: return "Notice"
        case 2: return "Persist"
        default: return "Took over"
        }
    }

    func calculateAdherenceStats(monthData: [Int]) -> (followedDays: Int, totalDays: Int, percentage: Int) {
        let totalDays = monthData.count
        let followedDays = monthData.filter { $0 == 1 }.count
        let percentage = totalDays > 0 ? Int(Double(followedDays) / Double(totalDays) * 100) : 0
        return (followedDays, totalDays, percentage)
    }

    func calculateTotalDaysFollowed() -> Int {
        var totalDays = 0
        for month in availableMonths {
            totalDays += month.adherenceData.filter { $0 == 1 }.count
        }
        return totalDays
    }

    func calculateCurrentStreak() -> Int {
        let allMonths = availableMonths
        var streak = 0

        for month in allMonths {
            for status in month.adherenceData.reversed() {
                if status == 1 {
                    streak += 1
                } else if status != 0 {
                    return streak
                }
            }
        }

        return streak
    }

    func calculateBestAllTimeStreak() -> Int {
        let allMonths = availableMonths.reversed()
        var maxStreak = 0
        var currentStreak = 0

        for month in allMonths {
            for status in month.adherenceData {
                if status == 1 {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else if status != 0 {
                    currentStreak = 0
                }
            }
        }

        return maxStreak
    }

    func calculateStreakInfo() -> (currentStreak: Int, bestAllTime: Int) {
        (calculateCurrentStreak(), calculateBestAllTimeStreak())
    }
}

// MARK: - Hardcoded Data

private extension ProgresssView {

    var availableMonths: [MonthData] {
        [
            MonthData(
                id: "2026-01",
                displayName: "January 2026",
                adherenceData: [
                    0, 0,
                    1, 1, 1, 2, 1,
                    1, 1, 1, 1, 3, 1, 1,
                    1, 2, 1, 1, 1, 3, 1,
                    1, 1, 1, 2, 1, 1, 2,
                    1, 1, 1, 1, 3
                ]
            ),
            MonthData(
                id: "2025-12",
                displayName: "December 2025",
                adherenceData: [
                    0, 0, 1, 1, 1, 1, 1,
                    1, 2, 1, 1, 1, 1, 2,
                    1, 1, 1, 3, 1, 1, 1,
                    1, 1, 2, 1, 1, 1, 1,
                    1, 1, 1
                ]
            ),
            MonthData(
                id: "2025-11",
                displayName: "November 2025",
                adherenceData: [
                    1, 1, 2, 1, 1, 1, 1,
                    3, 1, 1, 1, 2, 1, 1,
                    1, 1, 1, 1, 3, 1, 1,
                    1, 1, 1, 2, 1, 1, 1,
                    1, 1
                ]
            )
        ]
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

private struct MonthData: Identifiable {
    let id: String
    let displayName: String
    let adherenceData: [Int]
}
