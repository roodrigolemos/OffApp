//
//  SelectionStore.swift
//  Off
//

import FamilyControls

@MainActor
protocol SelectionStore {
    func loadSelection() throws -> FamilyActivitySelection
    func saveSelection(_ selection: FamilyActivitySelection) throws
}
