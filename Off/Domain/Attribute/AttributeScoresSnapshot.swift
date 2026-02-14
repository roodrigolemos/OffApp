//
//  AttributeScoresSnapshot.swift
//  Off
//

import Foundation

struct AttributeScoresSnapshot: Equatable {
    let scores: [Attribute: Int]
    let updatedAt: Date
}
