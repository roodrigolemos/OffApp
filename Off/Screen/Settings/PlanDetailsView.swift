//
//  PlanDetailsView.swift
//  Off
//

import SwiftUI
import FamilyControls
import ManagedSettingsUI

struct PlanDetailsView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager
    @Environment(UrgeManager.self) var urgeManager
    @Environment(InsightManager.self) var insightManager
    @Environment(StatsManager.self) var statsManager
    @Environment(ScreenTimeManager.self) var screenTimeManager

    @State private var showRulesEditor = false
    @State private var showActivityPicker = false
    @State private var activitySelection = FamilyActivitySelection()

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            if let plan = planManager.activePlan {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection(plan)
                        editActionsSection
                        scheduleSection(plan)
                        phoneRestrictionSection(plan)
                        appsSection
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                noPlanView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Plan Details")
        .fullScreenCover(isPresented: $showRulesEditor, onDismiss: refreshPlanState) {
            NavigationStack {
                PlanRulesEditView(dismissFlow: $showRulesEditor)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showRulesEditor = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.offTextSecondary)
                            }
                        }
                    }
            }
        }
        .familyActivityPicker(
            isPresented: $showActivityPicker,
            selection: $activitySelection
        )
        .onChange(of: activitySelection) {
            screenTimeManager.updateSelection(activitySelection)
        }
    }
}

// MARK: - Sections

private extension PlanDetailsView {

    var editActionsSection: some View {
        HStack(spacing: 10) {
            Button {
                showRulesEditor = true
            } label: {
                editActionButton(title: "Edit Rules", icon: "slider.horizontal.3")
            }
            .buttonStyle(.plain)

            Button {
                activitySelection = screenTimeManager.activitySelection
                showActivityPicker = true
            } label: {
                editActionButton(title: "Edit Apps", icon: "app.badge.fill")
            }
            .buttonStyle(.plain)
        }
    }

    func headerSection(_ plan: PlanSnapshot) -> some View {
        VStack(spacing: 26) {
            ZStack {
                Circle()
                    .fill(Color.offAccent.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: plan.displayIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            VStack(spacing: 8) {
                Text(plan.displayName)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)

                Text("Active for \(plan.activeDays) days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    func scheduleSection(_ plan: PlanSnapshot) -> some View {
        detailCard(title: "SCHEDULE") {
            VStack(alignment: .leading, spacing: 12) {
                detailRow(icon: "clock.fill", label: "Blocked", value: timeDescription(plan))
                detailRow(icon: "calendar", label: "Days", value: daysDescription(plan.days))
            }
        }
    }

    func phoneRestrictionSection(_ plan: PlanSnapshot) -> some View {
        detailCard(title: "PHONE RESTRICTION") {
            VStack(alignment: .leading, spacing: 12) {
                detailRow(
                    icon: "iphone",
                    label: "Restriction",
                    value: plan.phoneRestrictionMethod.displayName
                )

                if !plan.lightSupports.isEmpty {
                    detailRow(
                        icon: "checklist",
                        label: "Light Supports",
                        value: lightSupportsDescription(plan.lightSupports)
                    )
                }
            }
        }
    }
    
    var appsSection: some View {
        detailCard(title: "APPS") {
            appsSelectionSection
        }
    }

    var noPlanView: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color.offTextMuted)

            Text("No active plan")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.offTextSecondary)
        }
    }
}

// MARK: - Helper Views

private extension PlanDetailsView {

    var appsSelectionSection: some View {
        let tokens = Array(screenTimeManager.activitySelection.applicationTokens)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Current Selection")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.offTextMuted)

            if tokens.isEmpty {
                Text("No specific apps selected")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextPrimary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tokens, id: \.self) { token in
                        Label(token)
                            .labelStyle(.titleOnly)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.offTextPrimary)
                    }
                }
            }
        }
    }

    func editActionButton(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            Text(title)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(Color.offAccent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.offAccentSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.offAccent.opacity(0.28), lineWidth: 1)
        )
    }

    func detailCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
    }

    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offAccent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.offTextMuted)

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextPrimary)
            }
        }
    }
}

// MARK: - Helpers

private extension PlanDetailsView {

    func refreshPlanState() {
        planManager.loadPlan()
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
        insightManager.checkWeeklyInsightAvailability(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
    }

    func timeDescription(_ plan: PlanSnapshot) -> String {
        switch plan.timeBoundary {
        case .always:
            return "Always"
        case .duringWindows:
            guard let window = plan.timeWindows.first else { return "Blocked" }
            return "\(formatTime(hour: window.startHour, minute: window.startMinute))–\(formatTime(hour: window.endHour, minute: window.endMinute))"
        }
    }

    func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        if minute == 0 {
            return "\(displayHour) \(period)"
        }
        return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
    }

    func daysDescription(_ days: DaysOfWeek) -> String {
        if days == .everyday { return "Everyday" }
        if days == .weekdays { return "Weekdays" }
        if days == .weekends { return "Weekends" }

        let ordered: [(DaysOfWeek, String)] = [
            (.monday, "Mon"), (.tuesday, "Tue"), (.wednesday, "Wed"),
            (.thursday, "Thu"), (.friday, "Fri"), (.saturday, "Sat"), (.sunday, "Sun")
        ]
        let names = ordered.compactMap { days.contains($0.0) ? $0.1 : nil }
        return names.joined(separator: ", ")
    }

    func lightSupportsDescription(_ lightSupports: Set<LightSupport>) -> String {
        let displayOrder: [LightSupport] = [.notificationsOff, .removeFromHomeScreen, .logOut]
        let names = displayOrder.compactMap { lightSupports.contains($0) ? $0.displayName : nil }
        return names.joined(separator: ", ")
    }

}

#Preview {
    NavigationStack {
        PlanDetailsView()
    }
    .withPreviewManagers()
}
