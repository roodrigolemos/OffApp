//
//  UsageOpenReportCardView.swift
//  Off
//

import SwiftUI

struct UsageOpenReportCardView: View {

    var onOpen: () -> Void

    var body: some View {
        UsageProgressCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Usage tracking")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text("Your usage report is ready for today, last seven days, and last thirty days.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onOpen) {
                    Text("Open usage")
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
