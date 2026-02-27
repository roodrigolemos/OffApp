//
//  ScreenTimeManager.swift
//  Off
//

import Foundation
import Observation
import FamilyControls

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

    private let store: ScreenTimeStore

    var authorizationStatus: ScreenTimeAuthorizationStatus = .unknown
    var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    var error: ScreenTimeError?

    init(store: ScreenTimeStore) {
        self.store = store
    }

    convenience init() {
        self.init(store: UserDefaultsScreenTimeStore())
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

    var hasSelectedActivity: Bool {
        !activitySelection.applicationTokens.isEmpty
        || !activitySelection.categoryTokens.isEmpty
        || !activitySelection.webDomainTokens.isEmpty
    }
}

private extension ScreenTimeManager {

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
