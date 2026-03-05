//
//  UsageReportCardContainerView.swift
//  OffUsageReportExtension
//

import SwiftUI

struct UsageReportCardContainerView<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)

            content
                .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    Color(
                        red: 230.0 / 255.0,
                        green: 225.0 / 255.0,
                        blue: 217.0 / 255.0
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
