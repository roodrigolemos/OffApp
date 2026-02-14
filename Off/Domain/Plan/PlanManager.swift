//
//  PlanManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class PlanManager {
    
    private let store: PlanStore

    var activePlan: PlanSnapshot?
    var error: PlanError?

    init(store: PlanStore) {
        self.store = store
    }

    func loadPlan() {
        do {
            activePlan = try store.fetchActivePlan()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func createPlan(preset: PlanPreset, selectedApps: Set<SocialApp>) {
        do {
            let snapshot = PlanSnapshot(preset: preset, selectedApps: selectedApps, createdAt: .now)
            try store.save(snapshot)
            activePlan = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }
}
