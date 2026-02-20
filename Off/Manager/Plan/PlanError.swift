//
//  PlanError.swift
//  Off
//

import Foundation

enum PlanError: Error, LocalizedError {
    case noPresetSelected
    case saveFailed
    case loadFailed
    case invalidPlanName
    case notEnoughDays
    case noAppsSelected

    var errorDescription: String? {
        switch self {
        case .noPresetSelected: "No plan preset selected."
        case .saveFailed: "Could not save your plan."
        case .loadFailed: "Could not load your plan."
        case .invalidPlanName: "Please enter a name for your plan."
        case .notEnoughDays: "Please select at least 4 days."
        case .noAppsSelected: "Please select at least one app."
        }
    }
}
