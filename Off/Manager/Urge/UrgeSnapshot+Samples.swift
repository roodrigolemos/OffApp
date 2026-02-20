//
//  UrgeSnapshot+Samples.swift
//  Off
//

import Foundation

extension UrgeSnapshot {

    static let sample = UrgeSnapshot(
        timestamp: .now,
        predictedFeeling: .worse,
        seekingWhat: .distraction,
        memoryOfSuccess: .yesIRemember,
        finalChoice: .resisted,
        completedFull: true,
        screenReached: 6
    )
}
