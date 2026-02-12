//
//  ReframeIntroView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct ReframeIntroView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nothing is wrong with you")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("Your brain adapts to the kind of stimulation it gets.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)

                    Text("Fast, constant feedback pulls motivation toward what's easy, and makes effort feel heavier over time.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                Spacer()

                // Brain
                VStack(spacing: 12) {
                    Image("brainFullRot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)

                    Button { } label: {
                        Text("Give more stimulation")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.offAccentSoft)
                            )
                            .foregroundStyle(Color.offTextPrimary)
                    }
                    .buttonStyle(.plain)
                    .opacity(0.5)
                }

                Spacer()

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
}

#Preview {
    ReframeIntroView()
}
