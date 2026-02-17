//
//  MockCheckInStore.swift
//  Off
//

import Foundation

@MainActor
final class MockCheckInStore: CheckInStore {

    func fetchAll() throws -> [CheckInSnapshot] {
        let calendar = Calendar.current
        // Skip daysAgo == 3 to create a missed day gap
        let daysToGenerate = [1, 2, 4, 5]
        return daysToGenerate.compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) else { return nil }

            let adherence: PlanAdherence? = switch daysAgo {
            case 2: .partially
            case 4: .no
            case 5: nil
            default: .yes
            }

            return CheckInSnapshot(
                date: date,
                clarity: .better,
                focus: .same,
                energy: .better,
                drive: .same,
                patience: .better,
                control: .conscious,
                urgeLevel: .noticeable,
                planAdherence: adherence
            )
        }
    }

    func save(_ snapshot: CheckInSnapshot) throws { }
}
