//
//  CheckInView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct CheckInView: View {

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                titleSection
                headerSection
                attributesSection
                urgeSection
                planSection
                submitSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.offBackgroundPrimary)
    }

    // MARK: - Title

    private var titleSection: some View {
        HStack {
            Text("Check-in")
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
        .padding(.top, 16)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reflect on your day.")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Text("Answer based on how you feel today, since you started reducing social media.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    // MARK: - Attributes Section

    private var attributesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How your mind feels")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .padding(.top, 8)

            VStack(spacing: 12) {
                attributeCard(
                    icon: "brain.head.profile",
                    title: "Clarity",
                    subtitle: "Your mind feels",
                    options: ["Worse", "Same", "Better"],
                    selected: "Better"
                )
                attributeCard(
                    icon: "scope",
                    title: "Focus",
                    subtitle: "Sustaining attention feels",
                    options: ["Worse", "Same", "Better"],
                    selected: "Same"
                )
                attributeCard(
                    icon: "bolt.fill",
                    title: "Energy",
                    subtitle: "Your mental energy feels",
                    options: ["Worse", "Same", "Better"],
                    selected: nil
                )
                attributeCard(
                    icon: "flag.checkered",
                    title: "Drive",
                    subtitle: "Starting things feels",
                    options: ["Worse", "Same", "Better"],
                    selected: nil
                )
                attributeCard(
                    icon: "hand.raised.slash.fill",
                    title: "Control",
                    subtitle: "Your phone use feels",
                    options: ["Automatic", "Same", "Conscious"],
                    selected: nil
                )
                attributeCard(
                    icon: "hourglass",
                    title: "Patience",
                    subtitle: "Your tolerance for boredom feels",
                    options: ["Worse", "Same", "Better"],
                    selected: nil
                )
            }
        }
    }

    // MARK: - Urge Section

    private var urgeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Urge")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .padding(.top, 8)

            attributeCard(
                icon: "flame.fill",
                title: "Urge",
                subtitle: "How strong was your urge to use social media today?",
                options: ["None", "Noticeable", "Persistent", "Took over"],
                selected: "Noticeable"
            )
        }
    }

    // MARK: - Plan Section

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .padding(.top, 8)

            attributeCard(
                icon: "calendar.badge.checkmark",
                title: "Did you follow your plan today?",
                subtitle: "This is only used to interpret the weekly pattern.",
                options: ["Yes", "Partially", "No"],
                selected: "Yes"
            )
        }
    }

    // MARK: - Submit

    private var submitSection: some View {
        Button { } label: {
            HStack {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // MARK: - Attribute Card

    private func attributeCard(
        icon: String,
        title: String,
        subtitle: String,
        options: [String],
        selected: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = option == selected
                    Button { } label: {
                        Text(option)
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .foregroundStyle(isSelected ? .white : Color.offTextPrimary)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? Color.offAccent : Color.offBackgroundPrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview { CheckInView() }
