//
//  PlanAppsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct PlanAppsView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Which apps?")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("Pick the ones that most often pull you into autopilot.\nYou can always adjust this later.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Apps grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            appChip(icon: "camera.fill", name: "Instagram", selected: true)
                            appChip(icon: "play.rectangle.fill", name: "TikTok", selected: true)
                            appChip(icon: "play.tv.fill", name: "YouTube", selected: false)
                            appChip(icon: "bubble.left.fill", name: "Twitter / X", selected: false)
                            appChip(icon: "text.bubble.fill", name: "Facebook", selected: false)
                            appChip(icon: "camera.metering.spot", name: "Snapchat", selected: false)
                            appChip(icon: "pin.fill", name: "Pinterest", selected: false)
                            appChip(icon: "message.fill", name: "Reddit", selected: false)
                        }
                        .frame(maxWidth: 520, alignment: .leading)

                        // Select all
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 14, weight: .medium))
                            Text("Apply to all apps")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.offTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.offAccentSoft)
                        )
                        .padding(.top, 6)

                        Spacer(minLength: 8)
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

    private func appChip(icon: String, name: String, selected: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.offAccent)

            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(selected ? .white : Color.offTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)

            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.offDotInactive)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(selected ? Color.offAccent : Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(selected ? Color.offAccent : Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    PlanAppsView()
}
