//
//  UsageView.swift
//  Off
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct UsageView: View {

    @Environment(ScreenTimeManager.self) var screenTimeManager
    @Environment(UsageManager.self) var usageManager

    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var hasLoadedInitialState: Bool = false
    @State private var showActivityPicker: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                screenContent
            }
            .navigationBarTitleDisplayMode(.inline)
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
}

private extension UsageView {

    @ViewBuilder
    var screenContent: some View {
        switch usageManager.snapshot.state {
        case .usageEnabled:
            DeviceActivityReport(.usageReport, filter: usageFilter)
                .id(screenTimeManager.selectionDigest)
        default:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection
                    setupContentSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    var headerSection: some View {
        Text("Usage")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offTextPrimary)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    var setupContentSection: some View {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            UsageRequiredSetupCardView(
                title: "Screen Time required",
                bodyText: "Off needs Screen Time access to block apps and show usage.",
                ctaTitle: "Enable Screen Time"
            ) {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }
        case .requiredSelection:
            UsageRequiredSetupCardView(
                title: "Choose apps",
                bodyText: "Select the apps Off should block and track.",
                ctaTitle: "Select apps"
            ) {
                openSelectionPicker()
            }
        case .usageEnabled:
            EmptyView()
        }
    }

    func openSelectionPicker() {
        activitySelection = screenTimeManager.activitySelection
        showActivityPicker = true
    }

    var usageFilter: DeviceActivityFilter {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        let interval = DateInterval(start: start, end: .now)

        return DeviceActivityFilter(
            segment: .daily(during: interval),
            applications: screenTimeManager.activitySelection.applicationTokens,
            categories: screenTimeManager.activitySelection.categoryTokens,
            webDomains: screenTimeManager.activitySelection.webDomainTokens
        )
    }
}

#Preview {
    UsageView()
        .withPreviewManagers()
}
