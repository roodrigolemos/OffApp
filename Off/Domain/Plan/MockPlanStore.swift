//
//  MockPlanStore.swift
//  Off
//

import Foundation

@MainActor
final class MockPlanStore: PlanStore {

    func fetchActivePlan() throws -> PlanSnapshot? {
        PlanSnapshot(
            preset: .eveningWindDown,
            selectedApps: [.instagram, .tiktok, .youtube],
            createdAt: .now
        )
    }

    func save(_ snapshot: PlanSnapshot) throws { }
}
