//
//  UsageLockedTrackingCardView.swift
//  Off
//

import SwiftUI

struct UsageLockedTrackingCardView: View {

    var onEnable: () -> Void

    var body: some View {
        UsageProgressCardContainerView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Usage tracking")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text("To show time and checks, Off needs Screen Time access and a tracked selection.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onEnable) {
                    Text("Enable usage tracking")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.offAccent)
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
