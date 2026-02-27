//
//  ScreenTimeStore.swift
//  Off
//

import Foundation
import FamilyControls

@MainActor
protocol ScreenTimeStore {
    func loadSelection() throws -> FamilyActivitySelection
    func saveSelection(_ selection: FamilyActivitySelection) throws
}

@MainActor
final class UserDefaultsScreenTimeStore: ScreenTimeStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSelection() throws -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: Keys.activitySelection) else {
            return FamilyActivitySelection()
        }

        return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    func saveSelection(_ selection: FamilyActivitySelection) throws {
        let data = try PropertyListEncoder().encode(selection)
        defaults.set(data, forKey: Keys.activitySelection)
    }
}

private extension UserDefaultsScreenTimeStore {
    
    enum Keys {
        static let activitySelection = "screenTimeActivitySelection"
    }
}
