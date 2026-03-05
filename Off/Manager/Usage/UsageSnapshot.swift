//
//  UsageSnapshot.swift
//  Off
//

import Foundation

enum UsageProgressState: Equatable {
    case requiredScreenTimePermission
    case requiredSelection
    case usageEnabled
}

struct UsageProgressSnapshot: Equatable {
    let state: UsageProgressState
}
