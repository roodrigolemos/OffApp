//
//  PlanPresetsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct PlanPresetsView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pick your plan")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("You can customize or change your plan anytime later.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Presets
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        presetCard(icon: "moon.stars.fill", name: "Evening Wind-Down", subtitle: "Wind down before bed.", detail: "When: after 8 PM\nDays: every day\nPhone: log out", isSelected: true)
                        presetCard(icon: "briefcase.fill", name: "Weekday Detox", subtitle: "Stay focused on weekdays.", detail: "When: never\nDays: Mon–Fri\nPhone: delete apps", isSelected: false)
                        presetCard(icon: "fork.knife", name: "Lunch Break Only", subtitle: "Allow only during lunch.", detail: "When: 12–1 PM\nDays: every day\nPhone: hidden + silent", isSelected: false)
                        presetCard(icon: "target", name: "Purpose First", subtitle: "Social after priorities.", detail: "Condition: after tasks done\nDays: every day\nPhone: silent", isSelected: false)
                        presetCard(icon: "sunrise.fill", name: "Morning Focus", subtitle: "No social until afternoon.", detail: "When: after 12 PM\nDays: Mon–Fri\nPhone: hidden", isSelected: false)
                        Spacer(minLength: 10)
                    }
                    .padding(.bottom, 12)
                }

                // CTA
                Button { } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                        )
                        .foregroundStyle(.white)
                }
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }
    }

    private func presetCard(icon: String, name: String, subtitle: String, detail: String, isSelected: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 20))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.92)

                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextMuted)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
                    .padding(.top, 2)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.offAccent : Color.offDotInactive)
                .font(.title3)
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(isSelected ? 0.12 : 0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    PlanPresetsView()
}
