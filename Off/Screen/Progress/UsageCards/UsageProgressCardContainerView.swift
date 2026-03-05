//
//  UsageProgressCardContainerView.swift
//  Off
//

import SwiftUI

struct UsageProgressCardContainerView<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            content
                .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
