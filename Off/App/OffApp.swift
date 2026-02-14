//
//  OffApp.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import SwiftData

enum BuildConfiguration {
    case mock, dev, prod
}

@main
struct OffApp: App {

    @State private var appState: AppState
    @State private var attributeManager: AttributeManager
    @State private var planManager: PlanManager
    
    private let container: ModelContainer
    private let config: BuildConfiguration

    init() {
        do {
            let schema = Schema([AttributeScores.self, Plan.self])
            let modelConfig = ModelConfiguration("Off.store", schema: schema)
            container = try ModelContainer(for: schema, configurations: modelConfig)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }

        #if MOCK
        config = .mock
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        _appState = State(initialValue: AppState())

        switch config {
        case .mock:
            _attributeManager = State(initialValue: AttributeManager(store: MockAttributeStore()))
            _planManager = State(initialValue: PlanManager(store: MockPlanStore()))
        case .dev, .prod:
            _attributeManager = State(initialValue: AttributeManager(
                store: SwiftDataAttributeStore(context: container.mainContext)
            ))
            _planManager = State(initialValue: PlanManager(
                store: SwiftDataPlanStore(context: container.mainContext)
            ))
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .preferredColorScheme(.light)
                .environment(appState)
                .environment(attributeManager)
                .environment(planManager)
        }
    }
}
