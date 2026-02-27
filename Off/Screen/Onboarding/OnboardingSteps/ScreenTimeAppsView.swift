//
//  ScreenTimeAppsView.swift
//  Off
//

import SwiftUI
import FamilyControls

struct ScreenTimeAppsView: View {

    @Environment(ScreenTimeManager.self) var screenTimeManager

    @State private var activitySelection = FamilyActivitySelection()
    @State private var showActivityPicker = false
    @State private var hasLoadedInitialState = false

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                noticeSection
                Spacer()
                ctaSection
            }
            .padding(.horizontal, 24)
        }
        .familyActivityPicker(
            isPresented: $showActivityPicker,
            selection: $activitySelection
        )
        .onAppear {
            guard !hasLoadedInitialState else { return }
            hasLoadedInitialState = true
            activitySelection = screenTimeManager.activitySelection
        }
        .onChange(of: activitySelection) {
            screenTimeManager.updateSelection(activitySelection)
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

private extension ScreenTimeAppsView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select social media apps")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Select the apps that most distract you or take the most of your time.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    var noticeSection: some View {
        VStack(spacing: 10) {
            if shouldShowAuthorizationReminder {
                noticeCard(
                    icon: "shield.lefthalf.filled",
                    message: "Grant Screen Time permission first to get full app and category access."
                )
            }

            if isSimulator {
                noticeCard(
                    icon: "iphone.gen1",
                    message: "On Simulator, iOS may only show categories. To select specific apps, test on a real iPhone."
                )
            }
        }
        .padding(.bottom, 8)
    }

    var ctaSection: some View {
        VStack(spacing: 10) {
            Button {
                showActivityPicker = true
            } label: {
                Text("Select Apps")
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
            .disabled(!hasSelection)
            .opacity(hasSelection ? 1 : 0.45)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    var hasSelection: Bool {
        !activitySelection.applicationTokens.isEmpty
        || !activitySelection.categoryTokens.isEmpty
        || !activitySelection.webDomainTokens.isEmpty
    }

    var shouldShowAuthorizationReminder: Bool {
        screenTimeManager.authorizationStatus != .approved
    }

    var isSimulator: Bool {
#if targetEnvironment(simulator)
        true
#else
        false
#endif
    }

    func noticeCard(icon: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offWarn)
                .padding(.top, 1)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
    }
}

#Preview {
    ScreenTimeAppsView(onNext: {})
        .withPreviewManagers()
}
