//
//  AttributeScores.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class AttributeScores {
    
    var clarity: Int
    var focus: Int
    var energy: Int
    var drive: Int
    var control: Int
    var patience: Int
    var updatedAt: Date

    init(clarity: Int, focus: Int, energy: Int, drive: Int, control: Int, patience: Int, updatedAt: Date) {
        self.clarity = clarity
        self.focus = focus
        self.energy = energy
        self.drive = drive
        self.control = control
        self.patience = patience
        self.updatedAt = updatedAt
    }

    init(from snapshot: AttributeScoresSnapshot) {
        self.clarity = snapshot.scores[.clarity] ?? 3
        self.focus = snapshot.scores[.focus] ?? 3
        self.energy = snapshot.scores[.energy] ?? 3
        self.drive = snapshot.scores[.drive] ?? 3
        self.control = snapshot.scores[.control] ?? 3
        self.patience = snapshot.scores[.patience] ?? 3
        self.updatedAt = snapshot.updatedAt
    }

    func toSnapshot() -> AttributeScoresSnapshot {
        AttributeScoresSnapshot(
            scores: [
                .clarity: clarity,
                .focus: focus,
                .energy: energy,
                .drive: drive,
                .control: control,
                .patience: patience
            ],
            updatedAt: updatedAt
        )
    }
}
