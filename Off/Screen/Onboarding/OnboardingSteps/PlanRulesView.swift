//
//  PlanRulesView.swift
//  Off
//

import SwiftUI

struct PlanRulesView: View {

    @Environment(OnboardingManager.self) var manager

    @State private var planName: String = ""
    @State private var timeBoundary: TimeBoundary = .duringWindows
    @State private var timeWindows: [TimeWindowValue] = [TimeWindowValue(startHour: 12, startMinute: 0, endHour: 13, endMinute: 0)]
    @State private var days: DaysOfWeek = .everyday
    @State private var phoneRestrictionMethod: PhoneRestrictionMethod = .none
    @State private var lightSupports: Set<LightSupport> = []
    @State private var hasLoadedState = false

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    headerSection
                    nameCard
                    phoneRestrictionCard
                    if shouldShowLightSupports {
                        lightSupportsCard
                    }
                    timeCard
                    daysCard
                    ctaSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            guard !hasLoadedState else { return }
            hasLoadedState = true
            planName = manager.planName
            timeBoundary = manager.timeBoundary
            timeWindows = manager.timeWindows
            ensureTimeWindowsIfNeeded()
            days = manager.days
            phoneRestrictionMethod = manager.phoneRestrictionMethod
            lightSupports = manager.lightSupports
        }
        .onChange(of: timeBoundary) {
            ensureTimeWindowsIfNeeded()
        }
        .onChange(of: phoneRestrictionMethod) {
            lightSupports = phoneRestrictionMethod.normalized(lightSupports: lightSupports)
        }
    }
}

// MARK: - Sections

private extension PlanRulesView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Set your rules")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Define how and when your plan should apply.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

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
        .modifier(RulesCardStyle())
    }

    var timeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "clock.fill",
                       title: "Set Times",
                       subtitle: "When is social media not allowed?")

            VStack(spacing: 10) {
                timeOption(
                    icon: "clock.fill",
                    label: "Time windows",
                    description: "Not allowed at these times",
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
                    label: "Always",
                    description: "Not allowed at any time",
                    selected: timeBoundary == .always
                ) { timeBoundary = .always }
            }
        }
        .modifier(RulesCardStyle())
    }

    var shouldShowLightSupports: Bool {
        phoneRestrictionMethod != .deleteApps
    }

    var availableLightSupports: [LightSupport] {
        switch phoneRestrictionMethod {
        case .none:
            return [.notificationsOff, .removeFromHomeScreen, .logOut]
        case .screenTime:
            return [.notificationsOff, .removeFromHomeScreen]
        case .deleteApps:
            return []
        }
    }

    var phoneRestrictionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "iphone", title: "Phone Restriction", subtitle: "Pick one core method")

            VStack(spacing: 10) {
                restrictionOption(
                    icon: "sparkles",
                    label: "No restriction",
                    description: "Use lighter supports without hard phone blocks",
                    selected: phoneRestrictionMethod == .none
                ) {
                    phoneRestrictionMethod = .none
                }

                restrictionOption(
                    icon: "shield.fill",
                    label: "iOS Screen Time Shielding",
                    description: "Rely on scheduled shield restrictions",
                    selected: phoneRestrictionMethod == .screenTime
                ) {
                    phoneRestrictionMethod = .screenTime
                }

                restrictionOption(
                    icon: "trash.fill",
                    label: "Delete apps from iPhone",
                    description: "Remove social apps from your phone",
                    selected: phoneRestrictionMethod == .deleteApps
                ) {
                    phoneRestrictionMethod = .deleteApps
                }
            }
        }
        .modifier(RulesCardStyle())
    }

    var lightSupportsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "checklist", title: "Light Supports", subtitle: "Optional actions")

            VStack(spacing: 10) {
                ForEach(availableLightSupports, id: \.self) { lightSupport in
                    lightSupportOption(
                        icon: icon(for: lightSupport),
                        label: lightSupport.displayName,
                        description: description(for: lightSupport),
                        isOn: lightSupportBinding(for: lightSupport)
                    )
                }
            }
        }
        .modifier(RulesCardStyle())
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
        .modifier(RulesCardStyle())
    }

    var ctaSection: some View {
        Button {
            let windows = timeBoundary == .duringWindows ? timeWindows : []
            manager.setPlanRules(
                name: planName,
                timeBoundary: timeBoundary,
                timeWindows: windows,
                days: days,
                phoneRestrictionMethod: phoneRestrictionMethod,
                lightSupports: lightSupports
            )
            onNext()
        } label: {
            Text("Continue")
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
        }
        .disabled(!canContinue)
        .opacity(canContinue ? 1 : 0.45)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    var canContinue: Bool {
        !planName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && days.dayCount >= 4
    }
}

// MARK: - View Helpers

private extension PlanRulesView {

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
                selection: startTimeBinding(for: index),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Text("–")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextMuted)

            DatePicker(
                "",
                selection: endTimeBinding(for: index),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Spacer()

            if canDelete {
                Button {
                    guard timeWindows.indices.contains(index) else { return }
                    timeWindows.remove(at: index)
                    ensureTimeWindowsIfNeeded()
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

    func restrictionOption(icon: String, label: String, description: String, selected: Bool, action: @escaping () -> Void) -> some View {
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

    func lightSupportOption(icon: String, label: String, description: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
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

    func lightSupportBinding(for lightSupport: LightSupport) -> Binding<Bool> {
        Binding(
            get: { lightSupports.contains(lightSupport) },
            set: { isOn in
                if isOn {
                    lightSupports.insert(lightSupport)
                } else {
                    lightSupports.remove(lightSupport)
                }
            }
        )
    }

    func icon(for lightSupport: LightSupport) -> String {
        switch lightSupport {
        case .notificationsOff:
            return "bell.slash.fill"
        case .removeFromHomeScreen:
            return "apps.iphone"
        case .logOut:
            return "rectangle.portrait.and.arrow.right"
        }
    }

    func description(for lightSupport: LightSupport) -> String {
        switch lightSupport {
        case .notificationsOff:
            return "Stop social app push notifications"
        case .removeFromHomeScreen:
            return "Keep social apps out of your home screen"
        case .logOut:
            return "Use extra friction with account sign-out"
        }
    }

    func dateFrom(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
    }

    func startTimeBinding(for index: Int) -> Binding<Date> {
        Binding(
            get: {
                guard timeWindows.indices.contains(index) else {
                    return dateFrom(hour: 12, minute: 0)
                }
                let window = timeWindows[index]
                return dateFrom(hour: window.startHour, minute: window.startMinute)
            },
            set: { newDate in
                guard timeWindows.indices.contains(index) else { return }
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                timeWindows[index].startHour = comps.hour ?? 0
                timeWindows[index].startMinute = comps.minute ?? 0
            }
        )
    }

    func endTimeBinding(for index: Int) -> Binding<Date> {
        Binding(
            get: {
                guard timeWindows.indices.contains(index) else {
                    return dateFrom(hour: 13, minute: 0)
                }
                let window = timeWindows[index]
                return dateFrom(hour: window.endHour, minute: window.endMinute)
            },
            set: { newDate in
                guard timeWindows.indices.contains(index) else { return }
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                timeWindows[index].endHour = comps.hour ?? 0
                timeWindows[index].endMinute = comps.minute ?? 0
            }
        )
    }

    func ensureTimeWindowsIfNeeded() {
        guard timeBoundary == .duringWindows else { return }
        guard timeWindows.isEmpty else { return }
        timeWindows = [TimeWindowValue(startHour: 12, startMinute: 0, endHour: 13, endMinute: 0)]
    }
}

// MARK: - RulesCardStyle

private struct RulesCardStyle: ViewModifier {
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
    PlanRulesView(onNext: {})
        .environment(OnboardingManager())
}
