//
//  ReviewRequestView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct ReviewRequestView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("If Off makes sense to you")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("A quick rating helps a lot and supports this project.\nNo pressure — you can always do it later.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                VStack(spacing: 12) {

                    Button { } label: {
                        Text("Leave a review")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                            )
                            .foregroundStyle(.white)
                    }

                    Button { } label: {
                        Text("Continue without rating")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    ReviewRequestView()
}
