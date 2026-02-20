//
//  PlanDetailsView.swift
//  Off
//

import SwiftUI

struct PlanDetailsView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager
    @Environment(UrgeManager.self) var urgeManager
    @Environment(InsightManager.self) var insightManager
    @Environment(StatsManager.self) var statsManager

    @State private var showPlanSelection = false

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            if let plan = planManager.activePlan {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection(plan)
                        scheduleSection(plan)
                        phoneBehaviorSection(plan)
                        appsSection(plan)
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                noPlanView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Plan Details")
        .toolbar {
            if planManager.activePlan != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPlanSelection = true
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPlanSelection, onDismiss: {
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
        }) {
            NavigationStack {
                PlanSelectionView(dismissFlow: $showPlanSelection)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showPlanSelection = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.offTextSecondary)
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Sections

private extension PlanDetailsView {

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
                detailRow(icon: "clock.fill", label: "When", value: timeDescription(plan))
                detailRow(icon: "calendar", label: "Days", value: daysDescription(plan.days))
                if let condition = plan.condition, !condition.isEmpty {
                    detailRow(icon: "checkmark.seal.fill", label: "Condition", value: condition)
                }
            }
        }
    }

    func phoneBehaviorSection(_ plan: PlanSnapshot) -> some View {
        let items = phoneBehaviorItems(plan.phoneBehavior)
        return Group {
            if !items.isEmpty {
                detailCard(title: "PHONE BEHAVIOR") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(items, id: \.self) { item in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.offAccent)

                                Text(item)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.offTextPrimary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func appsSection(_ plan: PlanSnapshot) -> some View {
        detailCard(title: "APPS") {
            let apps = plan.selectedApps.sorted { $0.displayName < $1.displayName }
            FlowLayout(spacing: 8) {
                ForEach(apps, id: \.self) { app in
                    HStack(spacing: 6) {
                        Image(systemName: app.icon)
                            .font(.system(size: 12, weight: .medium))
                        Text(app.displayName)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Color.offAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.offAccent.opacity(0.1))
                    )
                }
            }
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

            Button {
                showPlanSelection = true
            } label: {
                Text("Create a Plan")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.offAccent)
                    )
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Helper Views

private extension PlanDetailsView {

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

    func timeDescription(_ plan: PlanSnapshot) -> String {
        switch plan.timeBoundary {
        case .anytime:
            return "Anytime"
        case .never:
            return "Never allowed"
        case .afterTime:
            if let after = plan.afterTime {
                return "After \(formatTime(hour: after.hour, minute: after.minute))"
            }
            return "After a set time"
        case .duringWindows:
            if plan.timeWindows.isEmpty { return "During set windows" }
            return plan.timeWindows.map { window in
                "\(formatTime(hour: window.startHour, minute: window.startMinute))–\(formatTime(hour: window.endHour, minute: window.endMinute))"
            }.joined(separator: ", ")
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

    func phoneBehaviorItems(_ behavior: PhoneBehavior) -> [String] {
        var items: [String] = []
        if behavior.removeFromHomeScreen { items.append("Remove from Home Screen") }
        if behavior.turnOffNotifications { items.append("Turn off notifications") }
        if behavior.logOutAccounts { items.append("Log out of accounts") }
        if behavior.deleteApps { items.append("Delete apps") }
        return items
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}

#Preview {
    NavigationStack {
        PlanDetailsView()
    }
    .withPreviewManagers()
}
