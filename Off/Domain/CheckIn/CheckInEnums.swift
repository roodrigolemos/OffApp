//
//  CheckInEnums.swift
//  Off
//

import Foundation

enum AttributeRating: Int, CaseIterable, Codable, Hashable {
    case worse = -1
    case same = 0
    case better = 1

    var label: String {
        switch self {
        case .worse: "Worse"
        case .same: "Same"
        case .better: "Better"
        }
    }
}

enum ControlRating: Int, CaseIterable, Codable, Hashable {
    case automatic = -1
    case same = 0
    case conscious = 1

    var label: String {
        switch self {
        case .automatic: "Automatic"
        case .same: "Same"
        case .conscious: "Conscious"
        }
    }
}

enum UrgeLevel: Int, CaseIterable, Codable, Hashable {
    case none = 0
    case noticeable = 1
    case persistent = 2
    case tookOver = 3

    var label: String {
        switch self {
        case .none: "None"
        case .noticeable: "Noticeable"
        case .persistent: "Persistent"
        case .tookOver: "Took over"
        }
    }
}

enum PlanAdherence: Int, CaseIterable, Codable, Hashable {
    case yes = 0
    case partially = 1
    case no = 2

    var label: String {
        switch self {
        case .yes: "Yes"
        case .partially: "Partially"
        case .no: "No"
        }
    }
}

enum DayAdherenceState: Equatable {
    case followed
    case partially
    case notFollowed
    case missed
    case pending
    case upcoming
    case restDay
}

struct WeekDayState: Equatable, Identifiable {
    let id: Int
    let label: String
    let state: DayAdherenceState
}
