//
//  PaywallView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct PaywallView: View {

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Continue your adaptation.")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.3)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("Your plan stays realistic — and Off keeps adjusting it with you over time.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 24)

                VStack(spacing: 14) {

                    // ── Benefits Card ──
                    VStack(alignment: .leading, spacing: 14) {
                        benefitRow(icon: "slider.horizontal.3", title: "Personalized plan", subtitle: "Pick what's realistic. Combine options. Adjust anytime.")

                        Divider().overlay(Color.offStroke)

                        benefitRow(icon: "brain.head.profile", title: "Mind check-ins", subtitle: "Track how your focus, energy, and clarity change over time.")

                        Divider().overlay(Color.offStroke)

                        benefitRow(icon: "arrow.triangle.2.circlepath", title: "Progressive adjustments", subtitle: "Small shifts that stick — without quitting everything.")
                    }
                    .padding(20)
                    .frame(maxWidth: 520, alignment: .leading)
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

                    // ── Plan Picker ──
                    VStack(spacing: 12) {

                        // Yearly (selected)
                        Button { } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text("Yearly")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(Color.offTextPrimary)

                                        Text("Best value")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(
                                                Capsule().fill(Color.offAccent)
                                            )
                                    }

                                    Text("$29.99 / year")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.offTextSecondary)

                                    Text("Less than $2.50 / month")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.offTextMuted)
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.offAccent)
                                    .font(.title3)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.offBackgroundSecondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.offAccent, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        // Monthly (unselected)
                        Button { } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Monthly")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color.offTextPrimary)

                                    Text("$4.99 / month")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.offTextSecondary)

                                    Text("Flexible. Cancel anytime.")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.offTextMuted)
                                }

                                Spacer()

                                Image(systemName: "circle")
                                    .foregroundStyle(Color.offDotInactive)
                                    .font(.title3)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.offBackgroundSecondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.offStroke, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: 520)
                }

                Spacer()

                // ── CTA Section ──
                VStack(spacing: 10) {

                    Button { } label: {
                        Text("Start yearly")
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
                        Text("Restore purchases")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    Button { } label: {
                        Text("Not now")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.offTextMuted)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: 520)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    PaywallView()
}
