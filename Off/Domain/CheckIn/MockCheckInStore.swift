//
//  MockCheckInStore.swift
//  Off
//

import Foundation

@MainActor
final class MockCheckInStore: CheckInStore {

    func fetchAll() throws -> [CheckInSnapshot] {
        let calendar = Calendar.current
        return (1...4).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) else { return nil }
            return CheckInSnapshot(
                date: date,
                clarity: .better,
                focus: .same,
                energy: .better,
                drive: .same,
                patience: .better,
                control: .conscious,
                urgeLevel: .noticeable,
                planAdherence: daysAgo == 2 ? .partially : .yes
            )
        }
    }

    func save(_ snapshot: CheckInSnapshot) throws { }
}
