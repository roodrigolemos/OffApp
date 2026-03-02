//
//  SharedScreenTimeStore.swift
//  Off
//

import Foundation
import FamilyControls

struct ScreenTimeShieldingPlanConfig: Codable {
    var phoneRestrictionMethodRaw: String
    var timeBoundaryRaw: String
    var daysRaw: Int
    var startHour: Int?
    var startMinute: Int?
    var endHour: Int?
    var endMinute: Int?
}

@MainActor
protocol ScreenTimeStore {
    func loadSelection() throws -> FamilyActivitySelection
    func saveSelection(_ selection: FamilyActivitySelection) throws
    func loadPlanConfig() throws -> ScreenTimeShieldingPlanConfig?
    func savePlanConfig(_ config: ScreenTimeShieldingPlanConfig?) throws
}

@MainActor
final class SharedScreenTimeStore: ScreenTimeStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func loadSelection() throws -> FamilyActivitySelection {
        if let data = defaults.data(forKey: ScreenTimeSharedConstants.selectionKey) {
            return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        }

        return FamilyActivitySelection()
    }

    func saveSelection(_ selection: FamilyActivitySelection) throws {
        let data = try PropertyListEncoder().encode(selection)
        defaults.set(data, forKey: ScreenTimeSharedConstants.selectionKey)
    }

    func loadPlanConfig() throws -> ScreenTimeShieldingPlanConfig? {
        guard let data = defaults.data(forKey: ScreenTimeSharedConstants.planConfigKey) else { return nil }
        return try PropertyListDecoder().decode(ScreenTimeShieldingPlanConfig.self, from: data)
    }

    func savePlanConfig(_ config: ScreenTimeShieldingPlanConfig?) throws {
        guard let config else {
            defaults.removeObject(forKey: ScreenTimeSharedConstants.planConfigKey)
            return
        }
        let data = try PropertyListEncoder().encode(config)
        defaults.set(data, forKey: ScreenTimeSharedConstants.planConfigKey)
    }
}
