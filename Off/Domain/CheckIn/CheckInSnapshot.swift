//
//  CheckInSnapshot.swift
//  Off
//

import Foundation

struct CheckInSnapshot: Identifiable, Equatable {
    
    let id: UUID
    let date: Date
    let clarity: AttributeRating
    let focus: AttributeRating
    let energy: AttributeRating
    let drive: AttributeRating
    let patience: AttributeRating
    let control: ControlRating
    let urgeLevel: UrgeLevel
    let planAdherence: PlanAdherence?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        clarity: AttributeRating,
        focus: AttributeRating,
        energy: AttributeRating,
        drive: AttributeRating,
        patience: AttributeRating,
        control: ControlRating,
        urgeLevel: UrgeLevel,
        planAdherence: PlanAdherence?
    ) {
        self.id = id
        self.date = date
        self.clarity = clarity
        self.focus = focus
        self.energy = energy
        self.drive = drive
        self.patience = patience
        self.control = control
        self.urgeLevel = urgeLevel
        self.planAdherence = planAdherence
    }
}
