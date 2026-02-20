//
//  InsightSnapshot.swift
//  Off
//

import Foundation

struct InsightSnapshot: Identifiable, Equatable {

    let id: UUID
    let weekStartDate: Date
    let generatedAt: Date
    let whatsHappening: String
    let whyThisHappens: String
    let whatToExpect: String
    let patternIdentified: String?

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        generatedAt: Date = .now,
        whatsHappening: String,
        whyThisHappens: String,
        whatToExpect: String,
        patternIdentified: String? = nil
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.generatedAt = generatedAt
        self.whatsHappening = whatsHappening
        self.whyThisHappens = whyThisHappens
        self.whatToExpect = whatToExpect
        self.patternIdentified = patternIdentified
    }
}
