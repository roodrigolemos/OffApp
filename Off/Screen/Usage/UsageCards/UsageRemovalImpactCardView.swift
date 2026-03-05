//
//  UsageRemovalImpactCardView.swift
//  Off
//

import SwiftUI

struct UsageRemovalImpactCardView: View {

    let daysSinceRemoval: Int

    var body: some View {
        UsageProgressCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Social apps removed")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text("No social apps installed")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)

                Text("Days since removal: \(daysSinceRemoval)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
