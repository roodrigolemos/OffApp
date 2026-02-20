//
//  StatsTypes.swift
//  Off
//

import Foundation

struct AdherenceStreakMetrics: Equatable {
    let current: Int
    let bestEver: Int
    let totalDaysFollowed: Int
}

enum AdherenceCellState: Equatable {
    case padding
    case inactive
    case committedFollowed
    case committedMissed
    case offFollowed
    case offNeutral
    case todayNeutral
}

struct AdherenceDayCell: Identifiable, Equatable {
    let id: String
    let date: Date?
    let state: AdherenceCellState
}

struct AdherenceMonth: Identifiable, Equatable {
    let id: String
    let displayName: String
    let cells: [AdherenceDayCell]
    let numerator: Int
    let denominator: Int
    let percentage: Int
}
