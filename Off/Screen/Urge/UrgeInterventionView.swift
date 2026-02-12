//
//  UrgeInterventionView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct UrgeInterventionView: View {

    var body: some View {
        ZStack {
            // Background gradients
            LinearGradient(
                colors: [.offBackgroundPrimary, .offAccentSoft.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.offAccent.opacity(0.06), .clear],
                center: UnitPoint(x: 0.5, y: 0.15),
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.offAccent)
                        Text("Conscious Pause")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.offTextPrimary)
                    }

                    Spacer()

                    Button { } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.offTextSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.offBackgroundSecondary.opacity(0.6))
                                    .overlay(
                                        Circle()
                                            .stroke(.offStroke.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Placeholder content
                Text("Step content appears here")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.offTextMuted)

                Spacer()
            }
        }
    }
}

#Preview {
    UrgeInterventionView()
}
