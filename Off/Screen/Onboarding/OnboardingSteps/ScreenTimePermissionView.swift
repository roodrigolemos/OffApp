//
//  ScreenTimePermissionView.swift
//  Off
//

import SwiftUI

struct ScreenTimePermissionView: View {

    @Environment(ScreenTimeManager.self) var screenTimeManager

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                permissionCard
                Spacer()
                ctaSection
            }
            .padding(.horizontal, 24)
        }
        .alert(
            "Error",
            isPresented: .init(
                get: { screenTimeManager.error != nil },
                set: { if !$0 { screenTimeManager.error = nil } }
            ),
            actions: {
                Button("OK") { screenTimeManager.error = nil }
            },
            message: {
                Text(screenTimeManager.error?.localizedDescription ?? "")
            }
        )
    }
}

#Preview {
    ScreenTimePermissionView(onNext: {})
        .withPreviewManagers()
}

// MARK: - Sections
private extension ScreenTimePermissionView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connect Screen Time")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Allow Off to use Screen Time permissions so your plan can apply iOS restrictions when needed.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var permissionCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: statusIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(statusColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Permission status")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text(statusText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(statusColor)
                    }
                }

                Text(statusDescription)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var ctaSection: some View {
        VStack(spacing: 10) {
            Button {
                Task { await screenTimeManager.requestAuthorization() }
            } label: {
                Text("Grant Permission")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Button(action: onNext) {
                Text("Continue")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.offBackgroundSecondary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.offStroke, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 8)
    }

    var statusText: String {
        switch screenTimeManager.authorizationStatus {
        case .unknown:
            return "Not Connected"
        case .approved:
            return "Connected"
        case .denied:
            return "Denied"
        }
    }

    var statusDescription: String {
        switch screenTimeManager.authorizationStatus {
        case .unknown:
            return "Grant access to let Off configure Screen Time based on your plan."
        case .approved:
            return "You're all set. Off can now use Screen Time permissions."
        case .denied:
            return "Access was denied. You can continue now and enable it later in Settings."
        }
    }

    var statusColor: Color {
        switch screenTimeManager.authorizationStatus {
        case .unknown:
            return Color.offWarn
        case .approved:
            return Color.offSuccess
        case .denied:
            return Color.offWarn
        }
    }

    var statusIcon: String {
        switch screenTimeManager.authorizationStatus {
        case .unknown:
            return "hourglass"
        case .approved:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        }
    }
}
