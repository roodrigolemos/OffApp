//
//  ShieldMonitorExtension.swift
//  OffShieldMonitorExtension
//

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

private struct ScreenTimeShieldingPlanConfig: Codable {
    var phoneRestrictionModeRaw: String
    var timeBoundaryRaw: String
    var daysRaw: Int
    var startHour: Int?
    var startMinute: Int?
    var endHour: Int?
    var endMinute: Int?
}

private final class ShieldMonitorSharedStore {

    private let defaults: UserDefaults = UserDefaults(suiteName: ScreenTimeSharedConstants.appGroupIdentifier) ?? .standard

    func loadSelection() throws -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: ScreenTimeSharedConstants.selectionKey) else {
            return FamilyActivitySelection()
        }
        return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    func loadPlanConfig() throws -> ScreenTimeShieldingPlanConfig? {
        guard let data = defaults.data(forKey: ScreenTimeSharedConstants.planConfigKey) else { return nil }
        return try PropertyListDecoder().decode(ScreenTimeShieldingPlanConfig.self, from: data)
    }
}

final class ShieldMonitorExtension: DeviceActivityMonitor {

    private let managedSettingsStore = ManagedSettingsStore(named: .offShieldingStore)
    private let sharedStore = ShieldMonitorSharedStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        applyShieldingIfNeeded(now: .now)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        clearShielding()
    }
}

private extension ShieldMonitorExtension {

    func applyShieldingIfNeeded(now: Date) {
        do {
            guard
                let config = try sharedStore.loadPlanConfig(),
                config.phoneRestrictionModeRaw == "screenTime"
            else {
                clearShielding()
                return
            }

            let selection = try sharedStore.loadSelection()
            guard hasAnySelection(selection), shouldShieldNow(config: config, now: now) else {
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

    func shouldShieldNow(config: ScreenTimeShieldingPlanConfig, now: Date) -> Bool {
        guard isSelectedDay(config: config, date: now) else { return false }

        switch config.timeBoundaryRaw {
        case "always":
            return true
        case "duringWindows":
            guard
                let sh = config.startHour,
                let sm = config.startMinute,
                let eh = config.endHour,
                let em = config.endMinute
            else {
                return false
            }
            let current = currentMinutes(in: now)
            let start = (sh * 60) + sm
            let end = (eh * 60) + em
            return current >= start && current < end
        default:
            return false
        }
    }

    func isSelectedDay(config: ScreenTimeShieldingPlanConfig, date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let bit = 1 << (weekday - 1)
        return (config.daysRaw & bit) != 0
    }

    func currentMinutes(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return ((components.hour ?? 0) * 60) + (components.minute ?? 0)
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
