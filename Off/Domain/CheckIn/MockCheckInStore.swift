//
//  MockCheckInStore.swift
//  Off
//

import Foundation

@MainActor
final class MockCheckInStore: CheckInStore {

    func fetchAll() throws -> [CheckInSnapshot] {
        []
    }

    func save(_ snapshot: CheckInSnapshot) throws { }
}
