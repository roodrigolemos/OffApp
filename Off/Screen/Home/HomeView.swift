//
//  HomeView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct HomeView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(AttributeManager.self) var attributeManager
    @Environment(CheckInManager.self) var checkInManager

    @State private var showCheckIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection

                        if checkInManager.hasCheckedInToday {
                            checkInCompletedCard
                        } else {
                            checkInPromptCard
                        }

                        insightsGrid
                        weekProgressSection
                    }
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
            .task {
                planManager.loadPlan()
                attributeManager.loadScores()
                checkInManager.loadAll()
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showCheckIn, onDismiss: {
                checkInManager.loadAll()
            }) {
                CheckInView()
            }
            .animation(.easeInOut, value: checkInManager.hasCheckedInToday)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }
                }
            }
        }
    }
}

// MARK: - Sections

private extension HomeView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formattedDate)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            Text(greeting)
                .font(.system(size: 38, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 36)
    }

    var checkInPromptCard: some View {
        Button { showCheckIn = true } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.offAccent.opacity(0.03),
                                Color.offAccentSoft.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How's your\nmind today?")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(Color.offTextPrimary)
                            .lineSpacing(4)

                        Text("Tap to begin check-in")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)

                        Circle()
                            .fill(Color.offAccent.opacity(0.15))
                            .frame(width: 78, height: 78)

                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(28)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.offAccent.opacity(0.2),
                                Color.offAccent.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.offAccent.opacity(0.06), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    var checkInCompletedCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offSuccess.opacity(0.03),
                            Color.offSuccess.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Check-in\ncomplete")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .lineSpacing(4)

                    Text("See you tomorrow")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.offSuccess, Color.offSuccess.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Circle()
                        .fill(Color.offSuccess.opacity(0.15))
                        .frame(width: 78, height: 78)

                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(28)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.offSuccess.opacity(0.2),
                            Color.offSuccess.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.offSuccess.opacity(0.06), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    var insightsGrid: some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                streakCard
                planCard
            }

            thisWeekCard

            weekInsightCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var weekProgressSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("THIS WEEK")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    dayCard(
                        day: "MON", date: "3", isToday: false, hasCheckIn: true,
                        attributes: [
                            ("brain.head.profile", "arrow.up", Color.offAccent),
                            ("scope", "arrow.up", Color.offAccent),
                            ("bolt.fill", "equal", Color.offTextMuted),
                            ("flag.checkered", "arrow.up", Color.offAccent),
                            ("hand.raised.slash.fill", "arrow.up", Color.offAccent),
                            ("hourglass", "equal", Color.offTextMuted)
                        ],
                        urgeText: "Noticeable"
                    )
                    dayCard(
                        day: "TUE", date: "4", isToday: false, hasCheckIn: true,
                        attributes: [
                            ("brain.head.profile", "equal", Color.offTextMuted),
                            ("scope", "arrow.down", Color.offWarn),
                            ("bolt.fill", "arrow.up", Color.offAccent),
                            ("flag.checkered", "equal", Color.offTextMuted),
                            ("hand.raised.slash.fill", "equal", Color.offTextMuted),
                            ("hourglass", "arrow.up", Color.offAccent)
                        ],
                        urgeText: "None"
                    )
                    dayCard(
                        day: "WED", date: "5", isToday: false, hasCheckIn: true,
                        attributes: [
                            ("brain.head.profile", "arrow.up", Color.offAccent),
                            ("scope", "arrow.up", Color.offAccent),
                            ("bolt.fill", "arrow.up", Color.offAccent),
                            ("flag.checkered", "arrow.up", Color.offAccent),
                            ("hand.raised.slash.fill", "arrow.up", Color.offAccent),
                            ("hourglass", "arrow.up", Color.offAccent)
                        ],
                        urgeText: "None"
                    )
                    dayCard(day: "THU", date: "6", isToday: false, hasCheckIn: false, attributes: [], urgeText: nil)
                    dayCard(day: "FRI", date: "7", isToday: false, hasCheckIn: false, attributes: [], urgeText: nil)
                    dayCard(day: "SAT", date: "8", isToday: false, hasCheckIn: false, attributes: [], urgeText: nil)
                    dayCard(
                        day: "SUN", date: "9", isToday: true, hasCheckIn: false, attributes: [], urgeText: nil
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Helper Views

private extension HomeView {

    var streakCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
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
                                endRadius: 25
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("5")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.5)

                    Text("Day streak")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offTextSecondary)
                        .tracking(0.3)
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

    var planCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.5),
                            Color.offAccentSoft.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 44, height: 44)

                    Image(systemName: planManager.activePlan?.displayIcon ?? "questionmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text(planManager.activePlan?.displayName ?? "No Plan")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .lineSpacing(3)

                    Text("Active plan")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                        .tracking(0.3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.3),
                            Color.offAccent.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.offAccent.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    var thisWeekCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("THIS WEEK")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.offTextMuted)
                        .tracking(1.6)

                    Text("Your plan days")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    dayDot(label: "M", state: .filled)
                    dayDot(label: "T", state: .filled)
                    dayDot(label: "W", state: .partial)
                    dayDot(label: "T", state: .filled)
                    dayDot(label: "F", state: .partial)
                    dayDot(label: "S", state: .stroke)
                    dayDot(label: "S", state: .stroke)
                }
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

    var weekInsightCard: some View {
        Button { } label: {
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

                HStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.offAccent.opacity(0.12))
                                    .frame(width: 28, height: 28)

                                Image(systemName: "sparkles")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.offAccent)
                            }

                            Text("INSIGHT")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(Color.offAccent)
                                .tracking(1.4)
                        }

                        Text("Your weekly insight is ready")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.offTextPrimary)
                            .lineLimit(2)
                            .lineSpacing(2)

                        Text("Tap to view your week summary")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                            .tracking(0.2)
                    }

                    Spacer(minLength: 16)

                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.08))
                            .frame(width: 44, height: 44)

                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.offAccent)
                    }
                }
                .padding(24)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    enum DotState { case filled, partial, stroke }

    func dayDot(label: String, state: DotState) -> some View {
        VStack(spacing: 6) {
            Group {
                switch state {
                case .filled:
                    Circle()
                        .fill(Color.offAccent)
                        .frame(width: 8, height: 8)
                case .partial:
                    Circle()
                        .fill(Color.offAccent.opacity(0.4))
                        .frame(width: 8, height: 8)
                case .stroke:
                    Circle()
                        .stroke(Color.offStroke, lineWidth: 1)
                        .frame(width: 8, height: 8)
                }
            }

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(state == .stroke ? Color.offTextMuted : Color.offTextSecondary)
        }
    }

    func dayCard(
        day: String,
        date: String,
        isToday: Bool,
        hasCheckIn: Bool,
        attributes: [(icon: String, arrow: String, color: Color)],
        urgeText: String?
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            if isToday {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.offAccent.opacity(0.06),
                                Color.offAccentSoft.opacity(0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text(day)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(isToday ? Color.offAccent : Color.offTextMuted)
                        .tracking(1.2)

                    Text(date)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offTextSecondary)
                }

                if hasCheckIn {
                    VStack(spacing: 6) {
                        if attributes.count >= 2 {
                            HStack(spacing: 12) {
                                attributeItem(icon: attributes[0].icon, arrow: attributes[0].arrow, color: attributes[0].color)
                                attributeItem(icon: attributes[1].icon, arrow: attributes[1].arrow, color: attributes[1].color)
                            }
                        }
                        if attributes.count >= 4 {
                            HStack(spacing: 12) {
                                attributeItem(icon: attributes[2].icon, arrow: attributes[2].arrow, color: attributes[2].color)
                                attributeItem(icon: attributes[3].icon, arrow: attributes[3].arrow, color: attributes[3].color)
                            }
                        }
                        if attributes.count >= 6 {
                            HStack(spacing: 12) {
                                attributeItem(icon: attributes[4].icon, arrow: attributes[4].arrow, color: attributes[4].color)
                                attributeItem(icon: attributes[5].icon, arrow: attributes[5].arrow, color: attributes[5].color)
                            }
                        }
                    }

                    if let urgeText {
                        Text(urgeText)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.offTextMuted)
                            .tracking(0.2)
                            .padding(.top, 2)
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("–")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(Color.offTextMuted.opacity(0.4))

                        Text("No check-in")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.offTextMuted)
                            .tracking(0.2)
                    }
                    .frame(height: 80)
                }
            }
            .frame(width: 100)
            .padding(.vertical, 18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isToday ? Color.offAccent.opacity(0.25) : Color.offStroke, lineWidth: isToday ? 1.5 : 1)
        )
        .shadow(color: isToday ? Color.offAccent.opacity(0.08) : Color.black.opacity(0.02), radius: isToday ? 12 : 6, x: 0, y: isToday ? 6 : 3)
    }

    func attributeItem(icon: String, arrow: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.offAccent)

            Image(systemName: arrow)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Helpers

private extension HomeView {

    var formattedDate: String {
        Date.now.formatted(
            .dateTime.weekday(.wide).month(.abbreviated).day()
        ).uppercased()
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

#Preview {
    HomeView()
        .withPreviewManagers()
}
