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
        urgeManager: UrgeManager,
        statsManager: StatsManager,
        screenTimeManager: ScreenTimeManager,
        usageManager: UsageManager
    ) {
        planManager.loadPlan()
        attributeManager.loadScores()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        screenTimeManager.refreshAuthorizationStatus()
        screenTimeManager.loadSelection()
        attributeManager.runWeeklyEvolutionIfNeeded(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        insightManager.checkWeeklyInsightAvailability(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
        usageManager.recalculate(
            activePlan: planManager.activePlan,
            trackingState: screenTimeManager.usageTrackingState
        )
    }

    func refresh(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager,
        statsManager: StatsManager,
        screenTimeManager: ScreenTimeManager,
        usageManager: UsageManager
    ) {
        planManager.loadPlan()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        screenTimeManager.refreshAuthorizationStatus()
        screenTimeManager.loadSelection()
        attributeManager.runWeeklyEvolutionIfNeeded(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        insightManager.checkWeeklyInsightAvailability(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
        usageManager.recalculate(
            activePlan: planManager.activePlan,
            trackingState: screenTimeManager.usageTrackingState
        )
    }
}
