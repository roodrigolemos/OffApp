//
//  ScreenTimeManager.swift
//  Off
//

import Foundation
import Observation
import FamilyControls
import DeviceActivity
import ManagedSettings

enum ScreenTimeAuthorizationStatus {
    case unknown
    case approved
    case denied
}

enum ScreenTimeError: Error, LocalizedError {
    case requestFailed
    case loadSelectionFailed
    case saveSelectionFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "Could not request Screen Time permission."
        case .loadSelectionFailed:
            return "Could not load your selected apps."
        case .saveSelectionFailed:
            return "Could not save your selected apps."
        }
    }
}

@MainActor
@Observable
final class ScreenTimeManager {

    private enum MonitorWeekday: CaseIterable {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday

        var dayFlag: DaysOfWeek {
            switch self {
            case .sunday: .sunday
            case .monday: .monday
            case .tuesday: .tuesday
            case .wednesday: .wednesday
            case .thursday: .thursday
            case .friday: .friday
            case .saturday: .saturday
            }
        }

        var calendarWeekday: Int {
            switch self {
            case .sunday: 1
            case .monday: 2
            case .tuesday: 3
            case .wednesday: 4
            case .thursday: 5
            case .friday: 6
            case .saturday: 7
            }
        }

        var monitorName: DeviceActivityName {
            DeviceActivityName("off.shield.monitor.\(calendarWeekday)")
        }
    }

    private let store: ScreenTimeStore
    private let deviceActivityCenter: DeviceActivityCenter = DeviceActivityCenter()
    private let managedSettingsStore: ManagedSettingsStore = ManagedSettingsStore(named: .offShieldingStore)

    var authorizationStatus: ScreenTimeAuthorizationStatus = .unknown
    var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    var error: ScreenTimeError?
    var shieldingSyncErrorDescription: String?

    init(store: ScreenTimeStore) {
        self.store = store
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = mapAuthorizationStatus(AuthorizationCenter.shared.authorizationStatus)
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            refreshAuthorizationStatus()
            error = nil
        } catch {
            refreshAuthorizationStatus()
            self.error = .requestFailed
        }
    }

    func loadSelection() {
        do {
            activitySelection = try store.loadSelection()
            error = nil
        } catch {
            self.error = .loadSelectionFailed
        }
    }

    func updateSelection(_ selection: FamilyActivitySelection) {
        do {
            try store.saveSelection(selection)
            activitySelection = selection
            error = nil
        } catch {
            self.error = .saveSelectionFailed
        }
    }

    func syncShielding(activePlan: PlanSnapshot?) {
        do {
            let config = makeConfig(from: activePlan)
            try store.savePlanConfig(config)

            guard let activePlan else {
                disableAllShielding()
                return
            }

            let canApplyShielding =
                activePlan.phoneRestrictionMode == .screenTime
                && authorizationStatus == .approved
                && hasSelectedActivity

            guard canApplyShielding else {
                disableAllShielding()
                return
            }

            stopAllMonitoring()
            try startMonitoring(for: activePlan)
            applyCurrentShieldState(plan: activePlan)
            shieldingSyncErrorDescription = nil
        } catch {
            disableAllShielding()
            shieldingSyncErrorDescription = error.localizedDescription
        }
    }

    var hasSelectedActivity: Bool {
        !activitySelection.applicationTokens.isEmpty
        || !activitySelection.categoryTokens.isEmpty
        || !activitySelection.webDomainTokens.isEmpty
    }

    var isAuthorized: Bool {
        authorizationStatus == .approved
    }

    var usageTrackingState: UsageTrackingState {
        UsageTrackingState(
            isAuthorized: isAuthorized,
            hasSelection: hasSelectedActivity
        )
    }

    var selectionDigest: Int {
        var hasher = Hasher()
        hasher.combine(activitySelection.applicationTokens)
        hasher.combine(activitySelection.categoryTokens)
        hasher.combine(activitySelection.webDomainTokens)
        return hasher.finalize()
    }
}

private extension ScreenTimeManager {

    func makeConfig(from plan: PlanSnapshot?) -> ScreenTimeShieldingPlanConfig? {
        guard let plan else { return nil }
        let window = plan.timeWindows.first
        return ScreenTimeShieldingPlanConfig(
            phoneRestrictionModeRaw: plan.phoneRestrictionMode.rawValue,
            timeBoundaryRaw: plan.timeBoundary.rawValue,
            daysRaw: plan.days.rawValue,
            startHour: window?.startHour,
            startMinute: window?.startMinute,
            endHour: window?.endHour,
            endMinute: window?.endMinute
        )
    }

    func startMonitoring(for plan: PlanSnapshot) throws {
        for day in MonitorWeekday.allCases where plan.days.contains(day.dayFlag) {
            let schedule = schedule(for: day, plan: plan)
            try deviceActivityCenter.startMonitoring(day.monitorName, during: schedule)
        }
    }

    private func schedule(for day: MonitorWeekday, plan: PlanSnapshot) -> DeviceActivitySchedule {
        let start: DateComponents
        let end: DateComponents

        switch plan.timeBoundary {
        case .always:
            start = DateComponents(hour: 0, minute: 0, weekday: day.calendarWeekday)
            end = DateComponents(hour: 23, minute: 59, weekday: day.calendarWeekday)
        case .duringWindows:
            let window = plan.timeWindows.first ?? PlanTimeWindowRules.defaultWindow
            start = DateComponents(
                hour: window.startHour,
                minute: window.startMinute,
                weekday: day.calendarWeekday
            )
            end = DateComponents(
                hour: window.endHour,
                minute: window.endMinute,
                weekday: day.calendarWeekday
            )
        }

        return DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: true)
    }

    func applyCurrentShieldState(plan: PlanSnapshot, now: Date = .now) {
        guard shouldShieldNow(plan: plan, at: now), hasSelectedActivity else {
            clearShielding()
            return
        }
        applyShielding()
    }

    func shouldShieldNow(plan: PlanSnapshot, at now: Date) -> Bool {
        guard plan.days.contains(date: now) else { return false }
        switch plan.timeBoundary {
        case .always:
            return true
        case .duringWindows:
            let window = plan.timeWindows.first ?? PlanTimeWindowRules.defaultWindow
            let current = currentMinutes(in: now)
            let start = (window.startHour * 60) + window.startMinute
            let end = (window.endHour * 60) + window.endMinute
            return current >= start && current < end
        }
    }

    func currentMinutes(in date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return ((comps.hour ?? 0) * 60) + (comps.minute ?? 0)
    }

    func applyShielding() {
        managedSettingsStore.shield.applications = activitySelection.applicationTokens.isEmpty
            ? nil
            : activitySelection.applicationTokens

        managedSettingsStore.shield.applicationCategories = activitySelection.categoryTokens.isEmpty
            ? nil
            : .specific(activitySelection.categoryTokens, except: Set<ApplicationToken>())

        managedSettingsStore.shield.webDomains = activitySelection.webDomainTokens.isEmpty
            ? nil
            : activitySelection.webDomainTokens
    }

    func clearShielding() {
        managedSettingsStore.clearAllSettings()
    }

    func stopAllMonitoring() {
        for day in MonitorWeekday.allCases {
            deviceActivityCenter.stopMonitoring([day.monitorName])
        }
    }

    func disableAllShielding() {
        stopAllMonitoring()
        clearShielding()
    }

    func mapAuthorizationStatus(_ status: AuthorizationStatus) -> ScreenTimeAuthorizationStatus {
        switch status {
        case .approved:
            return .approved
        case .denied:
            return .denied
        case .notDetermined:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
}
