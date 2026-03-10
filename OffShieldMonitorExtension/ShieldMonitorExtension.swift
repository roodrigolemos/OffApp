//
//  ShieldMonitorExtension.swift
//  OffShieldMonitorExtension
//

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

private final class ShieldMonitorSharedStore {

    private let defaults: UserDefaults = UserDefaults(suiteName: ScreenTimeSharedConstants.appGroupIdentifier) ?? .standard

    func loadSelection() throws -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: ScreenTimeSharedConstants.selectionKey) else {
            return FamilyActivitySelection()
        }
        return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}

final class ShieldMonitorExtension: DeviceActivityMonitor {

    private let managedSettingsStore = ManagedSettingsStore(named: .offShieldingStore)
    private let sharedStore = ShieldMonitorSharedStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        applyShieldingIfNeeded()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        clearShielding()
    }
}

private extension ShieldMonitorExtension {

    func applyShieldingIfNeeded() {
        do {
            let selection = try sharedStore.loadSelection()
            guard hasAnySelection(selection) else {
                clearShielding()
                return
            }

            managedSettingsStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
            managedSettingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens, except: Set<ApplicationToken>())
            managedSettingsStore.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        } catch {
            clearShielding()
        }
    }

    func hasAnySelection(_ selection: FamilyActivitySelection) -> Bool {
        !selection.applicationTokens.isEmpty
            || !selection.categoryTokens.isEmpty
            || !selection.webDomainTokens.isEmpty
    }

    func clearShielding() {
        managedSettingsStore.clearAllSettings()
    }
}
