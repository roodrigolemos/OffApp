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

    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "Could not request Screen Time permission."
        }
    }
}

@MainActor
@Observable
final class ScreenTimeManager {

    var authorizationStatus: ScreenTimeAuthorizationStatus = .unknown
    var error: ScreenTimeError?

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
