//
//  ReframeHopeView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct ReframeHopeView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("You can get it back")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("Your brain adapted to the stimulus.\nIt can adapt back.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Small changes in what you feed your attention can shift how you feel, without quitting everything.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .lineLimit(3)
                        .minimumScaleFactor(0.95)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                Spacer()

                // Brain
                VStack(spacing: 12) {
                    Image("brainPerfectlyHealhty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)

                    Button { } label: {
                        Text("Remove stimulation")
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
                    Text("Show me how")
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
    ReframeHopeView()
}
