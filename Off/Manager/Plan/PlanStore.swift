//
//  PlanStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol PlanStore {
    func fetchActivePlan() throws -> PlanSnapshot?
    func fetchAllPlans() throws -> [PlanSnapshot]
    func save(_ snapshot: PlanSnapshot) throws
    func deleteAllPlans() throws
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
        return models.compactMap { $0.toSnapshot() }.first
    }

    func fetchAllPlans() throws -> [PlanSnapshot] {
        let descriptor = FetchDescriptor<Plan>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let models = try context.fetch(descriptor)
        return models.compactMap { $0.toSnapshot() }
    }

    func save(_ snapshot: PlanSnapshot) throws {
        let model = Plan(from: snapshot)
        context.insert(model)
        try context.save()
    }

    func deleteAllPlans() throws {
        let descriptor = FetchDescriptor<Plan>()
        let models = try context.fetch(descriptor)
        models.forEach { context.delete($0) }
        try context.save()
    }
}
