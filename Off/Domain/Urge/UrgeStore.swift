//
//  UrgeStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol UrgeStore {
    func fetchAll() throws -> [UrgeSnapshot]
    func save(_ snapshot: UrgeSnapshot) throws
}

@MainActor
final class SwiftDataUrgeStore: UrgeStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [UrgeSnapshot] {
        let descriptor = FetchDescriptor<UrgeIntervention>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: UrgeSnapshot) throws {
        let model = UrgeIntervention(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
