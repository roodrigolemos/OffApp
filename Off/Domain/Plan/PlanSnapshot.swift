//
//  PlanSnapshot.swift
//  Off
//

import Foundation

struct PlanSnapshot: Equatable {
    
    let preset: PlanPreset?
    let selectedApps: Set<SocialApp>
    let createdAt: Date
}
