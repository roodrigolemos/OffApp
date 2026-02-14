//
//  AttributeManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class AttributeManager {
    
    private let store: AttributeStore

    var scores: AttributeScoresSnapshot?
    var error: AttributeError?

    init(store: AttributeStore) {
        self.store = store
    }

    func loadScores() {
        do {
            scores = try store.fetchScores()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func setInitialScores(ratings: [Attribute: Int]) {
        do {
            let snapshot = AttributeScoresSnapshot(scores: ratings, updatedAt: .now)
            try store.saveScores(snapshot)
            scores = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }
}
