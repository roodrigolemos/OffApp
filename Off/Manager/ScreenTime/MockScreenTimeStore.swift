//
//  MockScreenTimeStore.swift
//  Off
//

import Foundation
import FamilyControls

@MainActor
final class MockScreenTimeStore: ScreenTimeStore {

    private var selection: FamilyActivitySelection
    private var planConfig: ScreenTimeShieldingPlanConfig?

    init(
        selection: FamilyActivitySelection = FamilyActivitySelection(),
        planConfig: ScreenTimeShieldingPlanConfig? = nil
    ) {
        self.selection = selection
        self.planConfig = planConfig
    }

    func loadSelection() throws -> FamilyActivitySelection {
        selection
    }

    func saveSelection(_ selection: FamilyActivitySelection) throws {
        self.selection = selection
    }

    func loadPlanConfig() throws -> ScreenTimeShieldingPlanConfig? {
        planConfig
    }

    func savePlanConfig(_ config: ScreenTimeShieldingPlanConfig?) throws {
        planConfig = config
    }
}
