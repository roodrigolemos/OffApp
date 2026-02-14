//
//  MockAttributeStore.swift
//  Off
//

import Foundation

@MainActor
final class MockAttributeStore: AttributeStore {

    func fetchScores() throws -> AttributeScoresSnapshot? {
        AttributeScoresSnapshot(
            scores: [
                .clarity: 3,
                .focus: 2,
                .energy: 3,
                .drive: 2,
                .control: 2,
                .patience: 3
            ],
            updatedAt: .now
        )
    }

    func saveScores(_ snapshot: AttributeScoresSnapshot) throws { }
}
