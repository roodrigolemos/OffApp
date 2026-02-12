//
//  SocialTimeView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct SocialTimeView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("About how much time goes into social media each day?")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(3)
                        .minimumScaleFactor(0.9)

                    Text("Just a quick estimate.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Options
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        timeOption("Less than 1 hour", isSelected: false)
                        timeOption("1–2 hours", isSelected: false)
                        timeOption("2–4 hours", isSelected: true)
                        timeOption("4–6 hours", isSelected: false)
                        timeOption("More than 6 hours", isSelected: false)
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

    private func timeOption(_ text: String, isSelected: Bool) -> some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? Color.offAccent : Color.offDotInactive)
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
    SocialTimeView()
}
