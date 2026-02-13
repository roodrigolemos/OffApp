//
//  AppView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct AppView: View {

    @Environment(\.scenePhase) var scenePhase

    @State var appState: AppState = AppState()

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
        .environment(appState)
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .previewEnvironment()
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: true))
        .previewEnvironment()
}
