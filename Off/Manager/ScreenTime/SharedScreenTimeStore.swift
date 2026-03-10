//
//  SharedScreenTimeStore.swift
//  Off
//

import Foundation
import FamilyControls

@MainActor
protocol ScreenTimeStore: SelectionStore {}

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
}
