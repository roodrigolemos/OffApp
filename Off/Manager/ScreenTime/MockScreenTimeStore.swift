//
//  MockScreenTimeStore.swift
//  Off
//

import Foundation
import FamilyControls

@MainActor
final class MockScreenTimeStore: ScreenTimeStore {

    private var selection: FamilyActivitySelection

    init(selection: FamilyActivitySelection = FamilyActivitySelection()) {
        self.selection = selection
    }

    func loadSelection() throws -> FamilyActivitySelection {
        selection
    }

    func saveSelection(_ selection: FamilyActivitySelection) throws {
        self.selection = selection
    }
}
