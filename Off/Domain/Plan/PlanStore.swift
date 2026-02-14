//
//  PlanStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol PlanStore {
    func fetchActivePlan() throws -> PlanSnapshot?
    func save(_ snapshot: PlanSnapshot) throws
}

@MainActor
final class SwiftDataPlanStore: PlanStore {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchActivePlan() throws -> PlanSnapshot? {
        let descriptor = FetchDescriptor<Plan>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.first?.toSnapshot()
    }

    func save(_ snapshot: PlanSnapshot) throws {
        let model = Plan(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
