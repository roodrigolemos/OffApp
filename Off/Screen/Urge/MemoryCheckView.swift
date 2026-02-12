//
//  MemoryCheckView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct MemoryCheckView: View {

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.offAccent.opacity(0.15))

            // Prompt
            Text("Think of a time you resisted and felt good after.")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.offTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Subtitle
            Text("Distraction often fades on its own.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.offTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Options
            VStack(spacing: 12) {
                optionButton(emoji: "\u{1F44D}", label: "Yes, I remember")
                optionButton(emoji: "\u{1F914}", label: "Don't remember")
                optionButton(emoji: "\u{1F645}", label: "Never happened")
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func optionButton(emoji: String, label: String) -> some View {
        Button { } label: {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.offTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.offBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.7), .offAccent.opacity(0.03)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.offStroke.opacity(0.7), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
        }
    }
}

#Preview {
    MemoryCheckView()
}
