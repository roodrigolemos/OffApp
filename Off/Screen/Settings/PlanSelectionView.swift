//
//  PlanSelectionView.swift
//  Off
//

import SwiftUI

struct PlanSelectionView: View {

    @Environment(PlanManager.self) var planManager

    @Binding var dismissFlow: Bool

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                presetsSection
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PlanPreset.self) { preset in
            PlanAppsSelectionView(dismissFlow: $dismissFlow, preset: preset)
        }
        .navigationDestination(for: String.self) { destination in
            if destination == "customPlan" {
                CustomPlanView(dismissFlow: $dismissFlow)
            }
        }
    }
}

// MARK: - Sections

private extension PlanSelectionView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Change your plan")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Pick a preset or create your own")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var presetsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                NavigationLink(value: "customPlan") {
                    customPlanCard
                }
                .buttonStyle(.plain)
                
                ForEach(PlanPreset.allCases) { preset in
                    NavigationLink(value: preset) {
                        presetCard(preset, isActive: planManager.activePlan?.preset == preset)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 10)
            }
            .padding(.bottom, 12)
        }
    }

}

// MARK: - Helper Views

private extension PlanSelectionView {

    func presetCard(_ preset: PlanPreset, isActive: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: preset.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(preset.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(preset.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.92)

                Text(preset.detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextMuted)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
                    .padding(.top, 2)
            }

            Spacer()

            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isActive ? Color.offAccent : Color.offDotInactive)
                .font(.title3)
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.offAccent.opacity(isActive ? 0.12 : 0.04), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isActive ? Color.offAccent : Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var customPlanCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Create your own")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text("Build a fully custom plan from scratch.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.offTextMuted)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.offAccentSoft.opacity(0.15), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        PlanSelectionView(dismissFlow: .constant(false))
    }
    .withPreviewManagers()
}
