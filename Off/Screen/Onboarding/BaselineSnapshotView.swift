//
//  BaselineSnapshotView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct BaselineSnapshotView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("This is your starting point.")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)

                    Text("No score. No judgment — just a snapshot we'll improve over time.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Usage bar
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                            .frame(width: 36, height: 36)

                        Image(systemName: "clock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Social media use")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)

                        Text("~3h / day")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.offTextPrimary)
                    }

                    Spacer()

                    Text("60d / year")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.offTextPrimary)
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

                // Metrics grid
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        metricTile(icon: "brain.head.profile", title: "Mental clarity", score: 2, description: "Mind feels foggy.")
                        metricTile(icon: "scope", title: "Focus", score: 3, description: "Focus comes and goes.")
                        metricTile(icon: "bolt.fill", title: "Energy", score: 4, description: "Energy feels more stable.")
                        metricTile(icon: "flag.checkered", title: "Ease to start", score: 2, description: "Starting feels heavy.")
                        metricTile(icon: "hand.raised.slash.fill", title: "Intentional use", score: 2, description: "Use happens on autopilot.")
                        metricTile(icon: "hourglass", title: "Patience", score: 3, description: "It varies.")
                    }
                    .padding(.top, 14)
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

    private func metricTile(icon: String, title: String, score: Int, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                        .frame(width: 28, height: 28)

                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                }

                Spacer()

                Text("\(score)/5")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(i < score ? Color.offAccent : Color.offStroke.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Text(description)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
        }
        .padding(16)
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
    BaselineSnapshotView()
}
