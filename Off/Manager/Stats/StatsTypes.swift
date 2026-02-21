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

struct UrgeTrendPoint: Identifiable, Equatable {
    let id: Int
    let dayIndex: Int
    let value: Double
}

enum UrgeTrendDirection: Equatable {
    case decreasing
    case increasing
    case stable
    case insufficientData

    var message: String {
        switch self {
        case .decreasing:
            return "Your urges have been easing compared to last week"
        case .increasing:
            return "Your urges have been stronger compared to last week"
        case .stable:
            return "Your urges have been steady compared to last week"
        case .insufficientData:
            return "Not enough check-ins this week to update your trend."
        }
    }
}

struct UrgeInsightsSnapshot: Equatable {
    let trendDirection: UrgeTrendDirection
    let urgeAdherenceMessage: String?

    var trendDirectionMessage: String {
        trendDirection.message
    }
}
