//
//  PlanError.swift
//  Off
//

import Foundation

enum PlanError: Error, LocalizedError {
    case noPresetSelected
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .noPresetSelected: "No plan preset selected."
        case .saveFailed: "Could not save your plan."
        case .loadFailed: "Could not load your plan."
        }
    }
}
