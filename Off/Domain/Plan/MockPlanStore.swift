//
//  MockPlanStore.swift
//  Off
//

import Foundation

@MainActor
final class MockPlanStore: PlanStore {

    func fetchActivePlan() throws -> PlanSnapshot? {
        let twelveDaysAgo = Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now
        return PlanSnapshot(
            preset: .eveningWindDown,
            selectedApps: [.instagram, .tiktok, .youtube],
            createdAt: twelveDaysAgo
        )
    }

    func save(_ snapshot: PlanSnapshot) throws { }
}
