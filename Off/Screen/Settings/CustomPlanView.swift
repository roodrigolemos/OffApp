//
//  CustomPlanView.swift
//  Off
//

import SwiftUI

struct CustomPlanView: View {

    @Environment(PlanManager.self) var planManager

    @Binding var dismissFlow: Bool

    @State private var planName = ""
    @State private var selectedIcon = "gearshape.fill"
    
    @State private var timeBoundary: TimeBoundary = .anytime
    @State private var afterTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? .now
    @State private var timeWindows: [TimeWindowValue] = [TimeWindowValue(startHour: 12, startMinute: 0, endHour: 13, endMinute: 0)]
    @State private var days: DaysOfWeek = .everyday
    @State private var selectedApps: Set<SocialApp> = []
    @State private var removeFromHomeScreen = false
    @State private var turnOffNotifications = false
    @State private var logOutAccounts = false
    @State private var deleteApps = false
    @State private var condition = ""

    private let iconOptions = [
        "gearshape.fill", "moon.stars.fill", "sunrise.fill", "bolt.fill",
        "leaf.fill", "flame.fill", "shield.fill", "target",
        "brain.head.profile.fill", "eye.slash.fill", "lock.fill", "bell.slash.fill",
        "hourglass", "sparkles", "heart.fill", "star.fill",
        "figure.walk", "book.fill"
    ]

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    nameCard
                    iconCard
                    timeCard
                    conditionCard
                    suggestionCard
                    daysCard
                    appsCard
                    saveButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Custom Plan")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            selectedApps = planManager.activePlan?.selectedApps ?? []
        }
        .alert(
            "Error",
            isPresented: .init(
                get: { planManager.error != nil },
                set: { if !$0 { planManager.error = nil } }
            ),
            actions: { Button("OK") { planManager.error = nil } },
            message: { Text(planManager.error?.localizedDescription ?? "") }
        )
    }
}

// MARK: - Sections

private extension CustomPlanView {

    var nameCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "pencil", title: "Plan Name", subtitle: "Give your plan a name")

            TextField("e.g. Night Owl Mode", text: $planName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextPrimary)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.offBackgroundPrimary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.offStroke, lineWidth: 1)
                )
        }
        .modifier(CardStyle())
    }

    var iconCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "square.grid.2x2.fill", title: "Icon",
                       subtitle: "Pick an icon for your plan")

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
                spacing: 10
            ) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedIcon == icon ? Color.offAccent : Color.offBackgroundPrimary)

                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(selectedIcon == icon ? .white : Color.offTextSecondary)
                        }
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selectedIcon == icon ? Color.offAccent : Color.offStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .modifier(CardStyle())
    }

    var timeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "clock.fill",
                       title: "When to Allow",
                       subtitle: "When is social allowed?")

            VStack(spacing: 10) {
                timeOption(
                    icon: "sun.max.fill",
                    label: "Anytime",
                    description: "No time restrictions",
                    selected: timeBoundary == .anytime
                ) { timeBoundary = .anytime }

                timeOption(
                    icon: "moon.fill",
                    label: "After a set time",
                    description: "Allow after a specific hour",
                    selected: timeBoundary == .afterTime
                ) { timeBoundary = .afterTime }

                if timeBoundary == .afterTime {
                    DatePicker("", selection: $afterTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.offBackgroundPrimary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.offStroke, lineWidth: 1)
                        )
                }

                timeOption(
                    icon: "clock.fill",
                    label: "Time windows",
                    description: "Allow during specific periods",
                    selected: timeBoundary == .duringWindows
                ) { timeBoundary = .duringWindows }

                if timeBoundary == .duringWindows {
                    VStack(spacing: 8) {
                        ForEach(timeWindows.indices, id: \.self) { index in
                            timeWindowRow(index: index, canDelete: timeWindows.count > 1)
                        }

                        if timeWindows.count < 5 {
                            addWindowButton {
                                timeWindows.append(TimeWindowValue(startHour: 9,
                                                                   startMinute: 0,
                                                                   endHour: 10, endMinute: 0))
                            }
                        }
                    }
                }

                timeOption(
                    icon: "xmark.circle.fill",
                    label: "Never",
                    description: "Block completely",
                    selected: timeBoundary == .never
                ) { timeBoundary = .never }
            }
            .animation(.easeInOut(duration: 0.25), value: timeBoundary)
        }
        .modifier(CardStyle())
    }

    var conditionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "checkmark.seal.fill",
                       title: "Condition",
                       subtitle: "Optional rule before opening apps")

            ZStack(alignment: .topLeading) {
                if condition.isEmpty {
                    Text("e.g. After finishing all tasks for the day")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextMuted)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $condition)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
                    .frame(minHeight: 80)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
        }
        .modifier(CardStyle())
    }

    var suggestionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "iphone", title: "Phone Suggestions", subtitle: "What to do with your phone")

            VStack(spacing: 10) {
                suggestionOption(icon: "apps.iphone", label: "Remove from Home Screen", description: "Hide apps from your home screen", isOn: $removeFromHomeScreen, disabled: deleteApps)
                suggestionOption(icon: "bell.slash.fill", label: "Turn off notifications", description: "Stop all push notifications", isOn: $turnOffNotifications, disabled: deleteApps)
                suggestionOption(icon: "rectangle.portrait.and.arrow.right", label: "Log out of accounts", description: "Sign out of all accounts", isOn: $logOutAccounts, disabled: deleteApps)
                suggestionOption(icon: "trash.fill", label: "Delete apps entirely", description: "Permanently remove apps", isOn: $deleteApps, disabled: false)
            }
        }
        .modifier(CardStyle())
        .onChange(of: deleteApps) {
            if deleteApps {
                removeFromHomeScreen = true
                turnOffNotifications = true
                logOutAccounts = true
            }
        }
    }

    var daysCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "calendar", title: "When rules apply", subtitle: "Select at least 4 days")

            HStack(spacing: 8) {
                dayPill(label: "M", day: .monday)
                dayPill(label: "T", day: .tuesday)
                dayPill(label: "W", day: .wednesday)
                dayPill(label: "T", day: .thursday)
                dayPill(label: "F", day: .friday)
                dayPill(label: "S", day: .saturday)
                dayPill(label: "S", day: .sunday)
            }
        }
        .modifier(CardStyle())
    }

    var appsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "app.badge.fill",
                       title: "Apps",
                       subtitle: "Which apps does this plan cover?")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(SocialApp.allCases, id: \.self) { app in
                    Button {
                        if selectedApps.contains(app) {
                            selectedApps.remove(app)
                        } else {
                            selectedApps.insert(app)
                        }
                    } label: {
                        appChip(app, selected: selectedApps.contains(app))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .modifier(CardStyle())
    }

    var saveButton: some View {
        Button {
            savePlan()
        } label: {
            Text("Save Plan")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.offAccent, Color.offAccent.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .foregroundStyle(.white)
                .shadow(color: Color.offAccent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.top, 8)
    }
}

// MARK: - View Helpers

private extension CustomPlanView {

    func cardHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func timeWindowRow(index: Int, canDelete: Bool) -> some View {
        HStack(spacing: 8) {
            DatePicker(
                "",
                selection: Binding(
                    get: { dateFrom(hour: timeWindows[index].startHour, minute: timeWindows[index].startMinute) },
                    set: { newDate in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                        timeWindows[index].startHour = comps.hour ?? 0
                        timeWindows[index].startMinute = comps.minute ?? 0
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Text("–")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextMuted)

            DatePicker(
                "",
                selection: Binding(
                    get: { dateFrom(hour: timeWindows[index].endHour, minute: timeWindows[index].endMinute) },
                    set: { newDate in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                        timeWindows[index].endHour = comps.hour ?? 0
                        timeWindows[index].endMinute = comps.minute ?? 0
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Spacer()

            if canDelete {
                Button {
                    timeWindows.remove(at: index)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.offWarn)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.offBackgroundPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
    }

    func addWindowButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                Text("Add window")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Color.offAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.offAccent.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            )
        }
        .buttonStyle(.plain)
    }

    func timeOption(icon: String, label: String, description: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(selected ? Color.offAccent : Color.offTextSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(selected ? Color.offAccent : Color.offDotInactive)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? Color.offAccent.opacity(0.08) : Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? Color.offAccent : Color.offStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func suggestionOption(icon: String, label: String, description: String, isOn: Binding<Bool>, disabled: Bool) -> some View {
        Button {
            if !disabled {
                isOn.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isOn.wrappedValue ? Color.offAccent : Color.offTextSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isOn.wrappedValue ? Color.offAccent : Color.offDotInactive)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isOn.wrappedValue ? Color.offAccent.opacity(0.08) : Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isOn.wrappedValue ? Color.offAccent : Color.offStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(disabled && label != "Delete apps entirely" ? 0.5 : 1)
    }

    func dayPill(label: String, day: DaysOfWeek) -> some View {
        let isSelected = days.contains(day)
        return Button {
            if isSelected {
                guard days.dayCount > 4 else { return }
                days.remove(day)
            } else {
                days.insert(day)
            }
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isSelected ? .white : Color.offTextSecondary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? Color.offAccent : Color.offBackgroundPrimary)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.offAccent.opacity(0.25) : .clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    func appChip(_ app: SocialApp, selected: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: app.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.offAccent)

            Text(app.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(selected ? .white : Color.offTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)

            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .white : Color.offDotInactive)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(selected ? Color.offAccent : Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(selected ? Color.offAccent : Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Helpers

private extension CustomPlanView {

    func savePlan() {
        let afterTimeValue: TimeValue?
        if timeBoundary == .afterTime {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: afterTime)
            afterTimeValue = TimeValue(hour: comps.hour ?? 21, minute: comps.minute ?? 0)
        } else {
            afterTimeValue = nil
        }

        let windows = timeBoundary == .duringWindows ? timeWindows : []

        let phoneBehavior = PhoneBehavior(
            removeFromHomeScreen: removeFromHomeScreen,
            turnOffNotifications: turnOffNotifications,
            logOutAccounts: logOutAccounts,
            deleteApps: deleteApps
        )

        let trimmedCondition = condition.trimmingCharacters(in: .whitespacesAndNewlines)

        planManager.createCustomPlan(
            name: planName,
            icon: selectedIcon,
            selectedApps: selectedApps,
            timeBoundary: timeBoundary,
            afterTime: afterTimeValue,
            timeWindows: windows,
            days: days,
            phoneBehavior: phoneBehavior,
            condition: trimmedCondition.isEmpty ? nil : trimmedCondition
        )

        if planManager.error == nil {
            dismissFlow = false
        }
    }

    func dateFrom(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
    }
}

// MARK: - CardStyle

private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.offBackgroundSecondary)

                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.offAccent.opacity(0.04), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        CustomPlanView(dismissFlow: .constant(false))
    }
    .withPreviewManagers()
}
