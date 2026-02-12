//
//  ExpectedResultsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct ExpectedResultsView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Great plan.")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("This plan is designed to gently reduce friction — and support better patterns over time.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {

                        // ── Time Delta Card ──
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                                        .frame(width: 28, height: 28)

                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                }

                                Text("Social time (estimated)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.offTextPrimary)

                                Spacer()
                            }

                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Now")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.offTextSecondary.opacity(0.75))

                                    Text("3h/day")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(Color.offTextPrimary)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.offTextSecondary.opacity(0.08))
                                )

                                Image(systemName: "arrow.right")
                                    .foregroundStyle(Color.offTextSecondary.opacity(0.6))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("With Off")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.offTextSecondary.opacity(0.75))

                                    Text("2h/day")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(Color.offTextPrimary)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.offTextSecondary.opacity(0.08))
                                )
                            }
                            .padding(.top, 2)

                            Text("That's about **7 days a year** back — without cutting social out completely.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.offTextSecondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                        }
                        .padding(20)
                        .frame(maxWidth: 520, alignment: .leading)
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

                        // ── Metrics Grid ──
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            resultTile(icon: "brain.head.profile", title: "Mental clarity", score: 3, delta: "+1", description: "Less mental fog over time.")
                            resultTile(icon: "scope", title: "Focus", score: 4, delta: "+1", description: "Easier to hold focus.")
                            resultTile(icon: "bolt.fill", title: "Energy", score: 5, delta: "+1", description: "More steady energy.")
                            resultTile(icon: "flag.checkered", title: "Ease to start", score: 3, delta: "+1", description: "Less resistance to start.")
                            resultTile(icon: "hand.raised.slash.fill", title: "Intentional use", score: 3, delta: "+1", description: "More intentional checking.")
                            resultTile(icon: "hourglass", title: "Patience", score: 4, delta: "+1", description: "Less urgency, more calm.")
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                    }
                }

                // CTA
                Button { } label: {
                    Text("Start my plan")
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

    private func resultTile(icon: String, title: String, score: Int, delta: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                        .frame(width: 28, height: 28)

                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.offAccent)

                    Text(delta)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.offTextPrimary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.offTextSecondary.opacity(0.10))
                )
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(i < score ? Color.offAccent : Color.offStroke.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Text(description)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary.opacity(0.70))
                .lineLimit(2)
                .minimumScaleFactor(0.95)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    }
}

#Preview {
    ExpectedResultsView()
}
