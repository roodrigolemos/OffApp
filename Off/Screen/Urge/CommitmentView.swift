//
//  CommitmentView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct CommitmentView: View {

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)

                    // Icon
                    Image(systemName: "flag.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.offAccent.opacity(0.15))

                    // Title
                    Text("Evening Wind-Down")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.offAccent)

                    // Subtitle
                    Text("No social media after 8pm")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.offTextPrimary)

                    // Quote card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 14))
                                .foregroundStyle(.offAccent)
                            Text("You said:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.offTextMuted)
                        }

                        Text("I want to sleep better and stop doomscrolling before bed.")
                            .font(.system(size: 15, weight: .regular))
                            .italic()
                            .foregroundStyle(.offTextPrimary)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.offAccentSoft.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.offAccent.opacity(0.15), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 24)

                    // Reflection question
                    Text("Will using now move you closer or further?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.offTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer(minLength: 20)
                }
            }

            // Continue button
            Button { } label: {
                Text("Continue")
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
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    CommitmentView()
}
