//
//  ImpactLoadingView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct ImpactLoadingView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Thinking")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)

                    Text("Understanding how this affects you...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.95)
                }
                .frame(maxWidth: 520, alignment: .leading)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    ImpactLoadingView()
}
