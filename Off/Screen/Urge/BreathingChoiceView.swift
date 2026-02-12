//
//  BreathingChoiceView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct BreathingChoiceView: View {

    var body: some View {
        GeometryReader { geo in
            let baseSize = geo.size.width * 0.45

            VStack(spacing: 32) {
                Spacer()

                // Title
                Text("Breathe with the circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.offTextPrimary)

                // Breathing circle visualization
                ZStack {
                    // Outer glow circles
                    Circle()
                        .fill(.offAccent.opacity(0.02))
                        .frame(width: baseSize * 1.5, height: baseSize * 1.5)

                    Circle()
                        .fill(.offAccent.opacity(0.03))
                        .frame(width: baseSize * 1.3, height: baseSize * 1.3)

                    Circle()
                        .fill(.offAccent.opacity(0.06))
                        .frame(width: baseSize * 1.15, height: baseSize * 1.15)

                    // Main circle with stroke
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.offAccent, .offAccent.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: baseSize, height: baseSize)

                    // Breathing text
                    Text("Breathe in...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.offAccent)
                }

                // Countdown
                Text("15")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.offTextMuted)

                Spacer()

                // Bottom buttons
                VStack(spacing: 14) {
                    Button { } label: {
                        Text("\u{2705} I won't use it")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.offAccent, .offAccent.opacity(0.85)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .offAccent.opacity(0.3), radius: 8, y: 4)
                            )
                    }

                    Button { } label: {
                        Text("\u{1F4F1} I'll use it knowing this")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.offTextMuted)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    BreathingChoiceView()
}
