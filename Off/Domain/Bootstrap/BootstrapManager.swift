//
//  BootstrapManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class BootstrapManager {

    func bootstrap(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager
    ) {
        planManager.loadPlan()
        attributeManager.loadScores()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        attributeManager.runWeeklyEvolutionIfNeeded(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        insightManager.checkWeeklyInsightAvailability(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
    }

    func refresh(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager
    ) {
        planManager.loadPlan()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        attributeManager.runWeeklyEvolutionIfNeeded(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        insightManager.checkWeeklyInsightAvailability(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
    }
}
