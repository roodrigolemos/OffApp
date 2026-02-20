//
//  CheckInStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol CheckInStore {
    func fetchAll() throws -> [CheckInSnapshot]
    func save(_ snapshot: CheckInSnapshot) throws
}

@MainActor
final class SwiftDataCheckInStore: CheckInStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [CheckInSnapshot] {
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: CheckInSnapshot) throws {
        let model = CheckIn(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
