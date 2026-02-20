//
//  OnboardingView.swift
//  Off
//
//  Created by Rodrigo Lemos on 12/02/26.
//

import SwiftUI

enum OnboardingStep {
    case welcome
    case mirrorState
    case reframeIntro
    case reframeHope
    case value
    case baselineAssessment
    case socialTime
    case impactLoading
    case socialImpact
    case baselineSnapshot
    case planPresets
    case planApps
    case expectedResults
    case reviewRequest
    case paywall
}

struct OnboardingView: View {

    @Environment(AppState.self) var appState
    @Environment(AttributeManager.self) var attributeManager
    @Environment(PlanManager.self) var planManager
    @Environment(OnboardingManager.self) var onboardingManager

    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView(onNext: { currentStep = .mirrorState })
            case .mirrorState:
                MirrorStateView(onNext: { currentStep = .reframeIntro })
            case .reframeIntro:
                ReframeIntroView(onNext: { currentStep = .reframeHope })
            case .reframeHope:
                ReframeHopeView(onNext: { currentStep = .value })
            case .value:
                ValueView(onNext: { currentStep = .baselineAssessment })
            case .baselineAssessment:
                BaselineAssessmentView(onNext: { currentStep = .socialTime })
            case .socialTime:
                SocialTimeView(onNext: { currentStep = .impactLoading })
            case .impactLoading:
                ImpactLoadingView(onNext: { currentStep = .socialImpact })
            case .socialImpact:
                SocialImpactView(onNext: { currentStep = .baselineSnapshot })
            case .baselineSnapshot:
                BaselineSnapshotView(onNext: { currentStep = .planPresets })
            case .planPresets:
                PlanPresetsView(onNext: { currentStep = .planApps })
            case .planApps:
                PlanAppsView(onNext: { currentStep = .expectedResults })
            case .expectedResults:
                ExpectedResultsView(onNext: { currentStep = .reviewRequest })
            case .reviewRequest:
                ReviewRequestView(onNext: { currentStep = .paywall })
            case .paywall:
                PaywallView(
                    onNext: { completeOnboarding() },
                    daysPerYear: onboardingManager.daysPerYear,
                    outcomeSummary: onboardingManager.outcomeSummary
                )
            }
        }
        .animation(.smooth, value: currentStep)
    }

    private func completeOnboarding() {
        attributeManager.setInitialScores(ratings: onboardingManager.baselineRatings)
        if let preset = onboardingManager.selectedPreset {
            planManager.createPlan(preset: preset,
                                   selectedApps: onboardingManager.selectedApps)
        }

        appState.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingView()
        .withPreviewManagers()
}
