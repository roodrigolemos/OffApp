//
//  UsageReportExtension.swift
//  OffUsageReportExtension
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct UsageReportExtension: DeviceActivityReportExtension {
    
    var body: some DeviceActivityReportScene {
        UsageReportScene { configuration in
            UsageReportContentView(configuration: configuration)
        }
    }
}
