//
//  UsageRequiredSetupCardView.swift
//  Off
//

import SwiftUI

struct UsageRequiredSetupCardView: View {

    let title: String
    let bodyText: String
    let ctaTitle: String
    var onTap: () -> Void

    var bodyView: some View {
        UsageProgressCardContainerView {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(bodyText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onTap) {
                    Text(ctaTitle)
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

    var body: some View {
        bodyView
    }
}
