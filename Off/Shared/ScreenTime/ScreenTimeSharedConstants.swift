//
//  ScreenTimeSharedConstants.swift
//  Off
//

import Foundation
import ManagedSettings

enum ScreenTimeSharedConstants {
    static let appGroupIdentifier = "group.rlemosapp.Off"
    static let selectionKey = "screenTimeActivitySelection"
}

extension ManagedSettingsStore.Name {
    static let offShieldingStore = Self("off.shielding.store")
}
