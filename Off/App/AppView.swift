//
//  AppView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct AppView: View {

    @Environment(\.scenePhase) var scenePhase
    @Environment(AppState.self) var appState
    @Environment(PlanManager.self) var planManager
    @Environment(AttributeManager.self) var attributeManager
    @Environment(CheckInManager.self) var checkInManager
    @Environment(InsightManager.self) var insightManager

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                OnboardingView()
            }
        )
        .task { bootstrap() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkInManager.calculateStreak(plan: planManager.activePlan)
                checkInManager.calculateWeekDays(plan: planManager.activePlan)
                insightManager.checkWeeklyInsightAvailability(
                    plan: planManager.activePlan,
                    checkIns: checkInManager.checkIns
                )
            }
        }
    }

    private func bootstrap() {
        planManager.loadPlan()
        attributeManager.loadScores()
        checkInManager.boot(plan: planManager.activePlan)
        insightManager.checkWeeklyInsightAvailability(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
    }
}

#Preview("AppView - Tabbar") {
    AppView()
        .environment(AppState(showTabBar: true))
        .withPreviewManagers()
}

#Preview("AppView - Onboarding") {
    AppView()
        .environment(AppState(showTabBar: false))
        .withPreviewManagers()
}
