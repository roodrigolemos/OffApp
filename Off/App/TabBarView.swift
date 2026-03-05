//
//  TabBarView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct TabBarView: View {

    @Environment(PlanManager.self) var planManager

    @State private var selectedTab: Tab = .home

    private enum Tab: Hashable {
        case home
        case insights
        case usage
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            InsightsView()
                .tag(Tab.insights)
                .tabItem {
                    Label("Insights", systemImage: "sparkles")
                }
            if shouldShowUsageTab {
                UsageView()
                    .tag(Tab.usage)
                    .tabItem {
                        Label("Usage", systemImage: "clock.fill")
                    }
            }
            SettingsView()
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.offAccent)
        .onAppear {
            normalizeSelectedTabForCurrentMode()
        }
        .onChange(of: currentPhoneRestrictionMode) { _, _ in
            normalizeSelectedTabForCurrentMode()
        }
    }
}

private extension TabBarView {

    var currentPhoneRestrictionMode: PhoneRestrictionMode {
        planManager.activePlan?.phoneRestrictionMode ?? .none
    }

    var shouldShowUsageTab: Bool {
        currentPhoneRestrictionMode != .deleteApps
    }

    func normalizeSelectedTabForCurrentMode() {
        guard currentPhoneRestrictionMode == .deleteApps, selectedTab == .usage else { return }
        selectedTab = .home
    }
}

#Preview {
    TabBarView()
        .withPreviewManagers()
}
