//
//  AttributeStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol AttributeStore {
    func fetchScores() throws -> AttributeScoresSnapshot?
    func saveScores(_ snapshot: AttributeScoresSnapshot) throws
}

@MainActor
final class SwiftDataAttributeStore: AttributeStore {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchScores() throws -> AttributeScoresSnapshot? {
        let descriptor = FetchDescriptor<AttributeScores>()
        let models = try context.fetch(descriptor)
        return models.first?.toSnapshot()
    }

    func saveScores(_ snapshot: AttributeScoresSnapshot) throws {
        let descriptor = FetchDescriptor<AttributeScores>()
        let existing = try context.fetch(descriptor)
        for model in existing {
            context.delete(model)
        }
        let model = AttributeScores(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
