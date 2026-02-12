//
//  WeeklyInsightDetailView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct WeeklyInsightDetailView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                titleSection
                headerSection
                whatsHappeningSection
                whyThisHappensSection
                whatToExpectSection
                patternSection
            }
            .padding(.bottom, 40)
        }
        .background(Color.offBackgroundPrimary)
    }

    // MARK: - Title

    private var titleSection: some View {
        HStack {
            Text("Week 3 Insight")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)

            Spacer()

            Button { } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.offBackgroundSecondary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.offAccent.opacity(0.12))
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                }

                Text("WEEKLY INSIGHT")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.offAccent)
                    .tracking(1.2)
            }

            Text("Monday, January 20")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: - What's Happening

    private var whatsHappeningSection: some View {
        insightSection(
            icon: "eye.fill",
            title: "What's Happening",
            content: "Your focus improved noticeably this week, especially on days when you followed the evening wind-down plan. Energy levels were more consistent, though control still fluctuates.",
            accentColor: Color.offAccent
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Why This Happens

    private var whyThisHappensSection: some View {
        insightSection(
            icon: "brain.head.profile",
            title: "Why This Happens",
            content: "When you reduce evening screen time, your brain gets more restorative rest. This compounds over days, making sustained attention easier and reducing the 'mental fog' feeling.",
            accentColor: Color(red: 0.6, green: 0.4, blue: 0.8)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - What to Expect

    private var whatToExpectSection: some View {
        insightSection(
            icon: "arrow.forward.circle.fill",
            title: "What to Expect",
            content: "If you maintain this pattern, expect clarity and focus to stabilize further. Control tends to improve last — it requires the deepest neural adaptation.",
            accentColor: Color(red: 0.3, green: 0.7, blue: 0.5)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Pattern Identified

    private var patternSection: some View {
        insightSection(
            icon: "waveform.path.ecg",
            title: "Pattern Identified",
            content: "Your check-ins show better scores on days after you followed your plan the night before. The evening routine is your strongest lever right now.",
            accentColor: Color(red: 0.9, green: 0.6, blue: 0.3)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Insight Section

    private func insightSection(
        icon: String,
        title: String,
        content: String,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accentColor)
                }

                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)
                    .tracking(0.3)
            }

            Text(content)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.offTextPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview { WeeklyInsightDetailView() }
