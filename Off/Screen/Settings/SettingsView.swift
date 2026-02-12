//
//  SettingsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct SettingsView: View {

    @State private var eveningReminderOn: Bool = true
    @State private var weeklyFeedbackOn: Bool = true
    @State private var patternInsightsOn: Bool = false

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    currentPlanSection
                    screenTimeSection
                    notificationsSection
                    accountDataSection
                }
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Text("Settings")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offTextPrimary)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
    }

    // MARK: - Current Plan

    private var currentPlanSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("CURRENT PLAN")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            currentPlanCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    private var currentPlanCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.offAccent.opacity(0.12))
                                .frame(width: 36, height: 36)

                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.offAccent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Default Plan")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.offTextPrimary)

                            Text("Active for 12 days")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.offTextSecondary)
                        }
                    }

                    Button { } label: {
                        Text("Modify Plan")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.offAccent.opacity(0.08))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
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

    // MARK: - Screen Time

    private var screenTimeSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("SCREEN TIME")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            screenTimeCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    private var screenTimeCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.offWarn.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: "hourglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offWarn)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Screen Time Integration")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.offWarn)
                                .frame(width: 6, height: 6)

                            Text("Not Connected")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.offWarn)
                        }
                    }
                }

                Text("Used to track social media usage patterns")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(2)

                Button { } label: {
                    HStack {
                        Spacer()
                        Text("Grant Permission")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
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

    // MARK: - Notifications

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("NOTIFICATIONS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            notificationsCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    private var notificationsCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Evening Check-in Reminder")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text("Daily reminder to check in")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $eveningReminderOn)
                        .tint(Color.offAccent)
                        .labelsHidden()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider()
                    .background(Color.offStroke)
                    .padding(.horizontal, 24)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Feedback Alert")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text("Get your weekly insights")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $weeklyFeedbackOn)
                        .tint(Color.offAccent)
                        .labelsHidden()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider()
                    .background(Color.offStroke)
                    .padding(.horizontal, 24)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pattern Insights")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text("Notifications about detected patterns")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $patternInsightsOn)
                        .tint(Color.offAccent)
                        .labelsHidden()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    // MARK: - Account & Data

    private var accountDataSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("ACCOUNT & DATA")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            VStack(spacing: 14) {
                accountActionRow(
                    icon: "square.and.arrow.up",
                    title: "Export Check-in History",
                    subtitle: "Download your data as CSV",
                    iconColor: Color.offAccent
                )

                accountActionRow(
                    icon: "creditcard",
                    title: "Manage Subscription",
                    subtitle: "View or change your plan",
                    iconColor: Color.offAccent
                )

                deleteDataButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    private func accountActionRow(icon: String, title: String, subtitle: String, iconColor: Color) -> some View {
        Button { } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text(subtitle)
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
        .buttonStyle(.plain)
    }

    private var deleteDataButton: some View {
        Button { } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.red.opacity(0.04))

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.red)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete All Data")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.red)

                        Text("This action cannot be undone")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview { SettingsView() }
