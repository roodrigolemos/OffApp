//
//  PlanPresetsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct PlanPresetsView: View {

    @Environment(OnboardingManager.self) var manager
    
    @State private var selectedPreset: PlanPreset?
    
    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                presetsSection
                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections

private extension PlanPresetsView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pick your plan")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Text("You can customize or change your plan anytime later.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var presetsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(PlanPreset.allCases) { preset in
                    Button {
                        selectedPreset = preset
                    } label: {
                        presetCard(preset, isSelected: selectedPreset == preset)
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 10)
            }
            .padding(.bottom, 12)
        }
    }

    var ctaSection: some View {
        Button {
            guard let preset = selectedPreset else { return }
            manager.setSelectedPreset(preset)
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
        .disabled(selectedPreset == nil)
        .opacity(selectedPreset == nil ? 0.45 : 1)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Views

private extension PlanPresetsView {

    func presetCard(_ preset: PlanPreset, isSelected: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 20))
                    .frame(width: 40, height: 40)

                Image(systemName: preset.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
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

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.offAccent : Color.offDotInactive)
                .font(.title3)
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(isSelected ? 0.12 : 0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    PlanPresetsView(onNext: {})
        .environment(OnboardingManager())
}
