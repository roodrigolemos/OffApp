//
//  OffApp.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

enum BuildConfiguration {
    case mock, dev, prod
}

@main
struct OffApp: App {

    init() {
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .preferredColorScheme(.light)
        }
    }
}

extension View {

    func previewEnvironment() -> some View {
        return self
    }
}

