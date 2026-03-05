//
//  UsageSnapshot.swift
//  Off
//

import Foundation

enum UsageProgressState: Equatable {
    case lockedTracking
    case requiredScreenTimePermission
    case requiredSelection
    case usageEnabled
    case removalImpact(daysSinceRemoval: Int)
}

struct UsageProgressSnapshot: Equatable {
    let state: UsageProgressState
}
