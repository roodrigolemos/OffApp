//
//  BaselineAssessmentView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct BaselineAssessmentView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Let's understand how you feel today")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(Color.offTextPrimary)
                            .tracking(-0.3)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)

                        Text("No need to be exact.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                            .lineSpacing(3)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: 520, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.bottom, 6)

                    // Ratings
                    VStack(spacing: 14) {
                        ratingRow(label: "Mental clarity", lowLabel: "Foggy", highLabel: "Clear", selected: 2)
                        ratingRow(label: "Focus", lowLabel: "Low", highLabel: "High", selected: 3)
                        ratingRow(label: "Energy", lowLabel: "Low", highLabel: "High", selected: 4)
                        ratingRow(label: "Ease to start", lowLabel: "Hard", highLabel: "Easy", selected: 2)
                        ratingRow(label: "Intentional use", lowLabel: "Autopilot", highLabel: "Intentional", selected: 2)
                        ratingRow(label: "Patience", lowLabel: "Urgent", highLabel: "Patient", selected: 3)
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
    }

    private func ratingRow(label: String, lowLabel: String, highLabel: String, selected: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        Text("\(i)")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(i == selected ? Color.offAccent : Color.offBackgroundSecondary)
                            )
                            .foregroundStyle(i == selected ? Color.white : Color.offTextSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(i == selected ? Color.clear : Color.offStroke, lineWidth: 1)
                            )
                    }
                }

                HStack {
                    Text(lowLabel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextMuted)
                    Spacer()
                    Text(highLabel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextMuted)
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
        .frame(maxWidth: 520, alignment: .leading)
    }
}

#Preview {
    BaselineAssessmentView()
}
