//
//  MockPlanStore.swift
//  Off
//

import Foundation

@MainActor
final class MockPlanStore: PlanStore {

    func fetchActivePlan() throws -> PlanSnapshot? {
        try fetchAllPlans().last
    }

    func fetchAllPlans() throws -> [PlanSnapshot] {
        let calendar = Calendar.current
        let fortyFiveDaysAgo = calendar.date(byAdding: .day, value: -45, to: .now) ?? .now
        let twentyDaysAgo = calendar.date(byAdding: .day, value: -20, to: .now) ?? .now

        return [
            PlanSnapshot(
                preset: .morningFocus,
                selectedApps: [.instagram, .tiktok, .youtube],
                createdAt: fortyFiveDaysAgo
            ),
            PlanSnapshot(
                preset: .eveningWindDown,
                selectedApps: [.instagram, .tiktok, .youtube],
                createdAt: twentyDaysAgo,
                firstPlanCreatedAt: fortyFiveDaysAgo
            )
        ]
    }

    func save(_ snapshot: PlanSnapshot) throws { }
}
