//
//  PreviewContainer.swift
//  Off
//

import SwiftUI

@MainActor
struct PreviewContainer {
    
    static let appState = AppState()
    static let attributeManager = AttributeManager(store: MockAttributeStore())
    static let planManager: PlanManager = {
        let manager = PlanManager(store: MockPlanStore())
        manager.loadPlan()
        return manager
    }()
    static let checkInManager: CheckInManager = {
        let manager = CheckInManager(store: MockCheckInStore())
        manager.loadAll()
        return manager
    }()
}

extension View {
    
    func withPreviewManagers() -> some View {
        self
            .environment(PreviewContainer.appState)
            .environment(PreviewContainer.attributeManager)
            .environment(PreviewContainer.planManager)
            .environment(PreviewContainer.checkInManager)
    }
}
