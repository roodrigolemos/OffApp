//
//  SocialImpactView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct SocialImpactView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("That time adds up")
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundStyle(Color.offTextPrimary)
                                .tracking(-0.3)
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)

                            Text("At this pace, social media adds up to about **60 full days a year**.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.offTextSecondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                        // Explanation
                        Text("When that much time goes into fast, endless content, the brain adapts to constant stimulation. Over time, it tends to:")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)

                        // Bullets
                        VStack(alignment: .leading, spacing: 12) {
                            impactBullet("Keep attention in a reactive loop.")
                            impactBullet("Make focus harder to sustain — even for simple tasks.")
                            impactBullet("Make mental rest feel less restorative.")
                        }

                        // Conclusion
                        Text("Even **30 minutes less per day** is about **7 full days a year** with less stimulation — without quitting everything.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    private func impactBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                    .frame(width: 28, height: 28)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
    }
}

#Preview {
    SocialImpactView()
}
