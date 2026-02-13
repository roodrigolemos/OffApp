//
//  PlanAppsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct PlanAppsView: View {

    @Environment(OnboardingManager.self) var manager

    @State private var selectedApps: Set<SocialApp> = []

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                appsSection
                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections

private extension PlanAppsView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Which apps?")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Text("Pick the ones that most often pull you into autopilot.\nYou can always adjust this later.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var appsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(SocialApp.allCases, id: \.self) { app in
                        Button {
                            if selectedApps.contains(app) {
                                selectedApps.remove(app)
                            } else {
                                selectedApps.insert(app)
                            }
                        } label: {
                            appChip(app, selected: selectedApps.contains(app))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: 520, alignment: .leading)

                // Select all
                Button {
                    if allSelected {
                        selectedApps.removeAll()
                    } else {
                        selectedApps = Set(SocialApp.allCases)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: allSelected ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 14, weight: .medium))
                        Text("Apply to all apps")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.offTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.offAccentSoft)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 6)

                Spacer(minLength: 8)
            }
            .padding(.bottom, 12)
        }
    }

    var ctaSection: some View {
        Button {
            manager.setSelectedApps(selectedApps)
            onNext()
        } label: {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                )
                .foregroundStyle(.white)
        }
        .disabled(selectedApps.isEmpty)
        .opacity(selectedApps.isEmpty ? 0.45 : 1)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

}

// MARK: - Views

private extension PlanAppsView {

    func appChip(_ app: SocialApp, selected: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: app.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.offAccent)

            Text(app.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(selected ? .white : Color.offTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)

            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.offDotInactive)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(selected ? Color.offAccent : Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(selected ? Color.offAccent : Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Helpers
private extension PlanAppsView {

    var allSelected: Bool {
        selectedApps.count == SocialApp.allCases.count
    }
}

#Preview {
    PlanAppsView(onNext: {})
        .environment(OnboardingManager())
}
