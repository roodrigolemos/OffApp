//
//  PreviewContainer.swift
//  Off
//

import SwiftUI

@MainActor
struct PreviewContainer {
    
    static let appState = AppState()
    
    static let attributeManager: AttributeManager = {
        let manager = AttributeManager(store: MockAttributeStore())
        manager.loadScores()
        return manager
    }()
    
    static let planManager: PlanManager = {
        let manager = PlanManager(store: MockPlanStore())
        manager.loadPlan()
        return manager
    }()
    
    static let checkInManager: CheckInManager = {
        let manager = CheckInManager(store: MockCheckInStore())
        manager.boot(plan: planManager.activePlan, planHistory: planManager.planHistory)
        return manager
    }()
    
    static let urgeManager: UrgeManager = {
        let manager = UrgeManager(store: MockUrgeStore())
        manager.loadInterventions()
        return manager
    }()
    
    static let insightManager = InsightManager(store: MockInsightStore(), aiService: MockAIService())
}

extension View {

    func withPreviewManagers() -> some View {
        self
            .environment(PreviewContainer.appState)
            .environment(PreviewContainer.attributeManager)
            .environment(PreviewContainer.planManager)
            .environment(PreviewContainer.checkInManager)
            .environment(PreviewContainer.urgeManager)
            .environment(PreviewContainer.insightManager)
    }
}
