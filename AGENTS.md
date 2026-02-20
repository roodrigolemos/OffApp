# Architecture: Screen → Manager → Store

This is the project architecture. Follow it strictly when creating, editing, or refactoring any code.

```
Screen (presentation)
  ↓ reads state, calls methods
Manager (business logic + state)
  ↓ delegates data operations
Store (data access)
```

---

## Layer 1: Screen

What it does: Displays data and forwards user actions. Nothing else.

Rules:
- Never imports SwiftData
- Never contains business logic or cross-manager calculations
- Reads state from Managers via @Environment
- Calls Manager methods for user actions
- Never calls Manager load methods in .task — bootstrap handles initial loading
- Uses onDismiss to reload data and recalculate after user actions in presented screens
- CAN hold local UI state via @State (see below)

### onDismiss Pattern

When a Screen presents another Screen that changes data (check-in, plan change, urge intervention), the presenting Screen reloads the affected Managers and recalculates stats in `onDismiss`. This is the only place Screens call Manager load methods — never in `.task`.

```swift
struct HomeView: View {
    @Environment(CheckInManager.self) var checkInManager
    @Environment(PlanManager.self) var planManager
    @Environment(UrgeManager.self) var urgeManager
    @Environment(InsightManager.self) var insightManager
    @Environment(StatsManager.self) var statsManager

    @State private var showCheckIn = false
    @State private var showUrgeIntervention = false

    var body: some View {
        VStack {
            // content using statsManager.streakMetrics, etc.
        }
        .fullScreenCover(isPresented: $showCheckIn, onDismiss: {
            checkInManager.loadCheckIns()
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
            CheckInView()
        }
        .fullScreenCover(isPresented: $showUrgeIntervention, onDismiss: {
            urgeManager.loadInterventions()
            statsManager.recalculate(
                checkIns: checkInManager.checkIns,
                activePlan: planManager.activePlan,
                planHistory: planManager.planHistory,
                interventions: urgeManager.interventions
            )
        }) {
            UrgeInterventionView()
        }
    }
}
```

Rules:
- Only reload the Manager whose data changed (checkInManager after check-in, urgeManager after intervention)
- Always recalculate stats after any data change that affects derived state
- Bootstrap handles initial loading — onDismiss handles mid-session changes

### View State Rule

Screens hold LOCAL UI state — things that only matter to that specific screen. They do NOT hold manager state (data, business logic, anything shared).

If it dies when the screen disappears and nobody cares, it's @State in the View.
If it needs to survive across screens or be shared, it's in the Manager.

```swift
struct CheckInView: View {
    @Environment(CheckInManager.self) var manager

    // ✅ Local UI state — belongs in the View
    @State private var selectedRating: Int = 5
    @State private var showConfirmation: Bool = false
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""

    // ❌ Manager state — belongs in the Manager
    // @State private var checkIns: [CheckInSnapshot] = []

    // ❌ Cross-manager derived state — belongs in StatsManager
    // @State private var streakMetrics = AdherenceStreakMetrics(...)

    var body: some View {
        VStack {
            Slider(value: .init(
                get: { Double(selectedRating) },
                set: { selectedRating = Int($0) }
            ), in: 1...10)

            Button("Submit") {
                manager.submitCheckIn(rating: selectedRating)
                showConfirmation = true
            }
        }
        .alert("Saved!", isPresented: $showConfirmation) { }
    }
}
```

### Structuring Large Views

When a View body gets too large, split it using this escalation:

1. **Start with computed properties** — handles 90% of cases
2. **Extract private child Views** — when a section needs its own @State or @Binding, keep in same file
3. **Extract to Components/** — only when the same View is used in 2+ screens
4. **Use +Helpers.swift extensions** — only when helper methods clutter the main file
5. **Never split a View across multiple files just because it's long** — a 200-line View with clear sections is better than 5 tiny files

```swift
// CheckInView.swift
struct CheckInView: View {
    @Environment(CheckInManager.self) var manager

    @State private var selectedRating: Int = 5
    @State private var showConfirmation: Bool = false

    var body: some View {
        ScrollView {
            headerSection
            ratingSection
            historySection
            submitButton
        }
        .alert("Saved!", isPresented: $showConfirmation) { }
    }
}

// MARK: - Sections
private extension CheckInView {

    var headerSection: some View {
        VStack(spacing: 8) {
            Text("Daily Check-In")
                .font(.title)
            Text("How are you feeling today?")
                .font(.subheadline)
        }
    }

    var ratingSection: some View {
        VStack {
            Slider(value: .init(
                get: { Double(selectedRating) },
                set: { selectedRating = Int($0) }
            ), in: 1...10)
            Text("\(selectedRating)/10")
        }
        .padding()
    }

    var historySection: some View {
        VStack {
            ForEach(manager.checkIns.prefix(5)) { checkIn in
                CheckInRow(checkIn: checkIn)
            }
        }
    }

    var submitButton: some View {
        Button("Submit") {
            manager.submitCheckIn(rating: selectedRating)
            showConfirmation = true
        }
    }
}
```

When a section is complex and needs its own state, extract a private child View in the same file:

```swift
// Still in CheckInView.swift
private struct RatingSlider: View {
    @Binding var rating: Int

    var body: some View {
        VStack {
            Slider(value: .init(
                get: { Double(rating) },
                set: { rating = Int($0) }
            ), in: 1...10)
            Text("\(rating)/10")
        }
    }
}
```

When a component is reused across multiple screens, it gets its own file in Components/:

```swift
// Components/CheckInRow.swift
struct CheckInRow: View {
    let checkIn: CheckInSnapshot

    var body: some View {
        HStack {
            Text(checkIn.date.formatted(.dateTime.month().day()))
            Spacer()
            Text("\(checkIn.rating)/10")
        }
    }
}
```

---

## Layer 2: Manager

What it does: Handles a specific topic in the app — its state, logic, and rules. A Manager is the single source of truth for its topic. Screens read from it, never compute or store that topic's data themselves.

A Manager may have persisted data with a Store, or it may hold computed/ephemeral state with no Store. The defining trait is: one topic, one Manager.

Rules:
- @MainActor @Observable
- Never imports SwiftUI
- One Manager per topic, not per screen
- Owns state that Screens read
- Contains computed properties, validation, transformations
- If it has a Store: delegates all data operations to the Store, reloads state after every save — never update state in-place manually
- Exposes only Snapshot structs, never @Model objects
- Never holds references to other Managers — receives external data as method parameters

Current Managers in Off:
- **PlanManager** — plans (apps, schedule, days)
- **CheckInManager** — daily self-reports (ratings, adherence)
- **AttributeManager** — the six wellness scores (evolution, momentum)
- **UrgeManager** — intervention sessions (timestamps, responses, outcomes)
- **InsightManager** — weekly AI feedback (narrative text, availability)
- **StatsManager** — derived state from multiple managers (streaks, adherence, trends)
- **BootstrapManager** — app startup and refresh sequencing
- **OnboardingManager** — onboarding flow state

```swift
@MainActor @Observable
final class CheckInManager {
    private let store: CheckInStore

    var checkIns: [CheckInSnapshot] = []
    var error: CheckInError?

    var hasCheckedInToday: Bool {
        checkIns.contains { Calendar.current.isDateInToday($0.date) }
    }

    init(store: CheckInStore) {
        self.store = store
    }

    func loadCheckIns() {
        do {
            checkIns = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func save(_ snapshot: CheckInSnapshot) {
        do {
            try store.save(snapshot)
            loadCheckIns()
        } catch {
            self.error = .saveFailed
        }
    }
}
```

---

## Layer 3: Store

What it does: Pure data access. CRUD operations against SwiftData, API, or mock.

Rules:
- Protocol-based (enables mock/prod switching)
- @MainActor
- Stateless — no properties, no cached state
- Converts @Model objects to Snapshot structs before returning
- One implementation per data source (SwiftData, Mock, API)

```swift
@MainActor
protocol CheckInStore {
    func fetchAll() throws -> [CheckInSnapshot]
    func save(_ snapshot: CheckInSnapshot) throws
    func delete(_ id: UUID) throws
}

@MainActor
final class SwiftDataCheckInStore: CheckInStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [CheckInSnapshot] {
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: CheckInSnapshot) throws {
        let model = CheckIn(from: snapshot)
        context.insert(model)
        try context.save()
    }

    func delete(_ id: UUID) throws {
        // fetch and delete
    }
}
```

---

## Manager Topics

Each Manager owns one topic. Some topics have persisted data (Store + Snapshots), some don't. The architecture is the same either way — Screens read from the Manager via @Environment.

### StatsManager

StatsManager computes and holds derived state from multiple Managers that multiple Screens read. It receives data from other Managers as method parameters and owns the computed results. Screens read via @Environment — no @State for derived data, no duplication across views.

```swift
@MainActor @Observable
final class StatsManager {

    var streakMetrics = AdherenceStreakMetrics(current: 0, bestEver: 0, totalDaysFollowed: 0)
    var adherenceMonths: [AdherenceMonth] = []
    var weekDays: [WeekDayState] = []
    var weekDayCards: [WeekDayCardData] = []
    var urgeTrend: [Double] = []

    func recalculate(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        interventions: [UrgeSnapshot]
    ) {
        streakMetrics = Self.computeStreakMetrics(
            checkIns: checkIns,
            activePlan: activePlan,
            planHistory: planHistory
        )
        adherenceMonths = Self.computeAdherenceMonths(
            checkIns: checkIns,
            activePlan: activePlan,
            planHistory: planHistory
        )
        weekDays = Self.computeWeekDays(
            checkIns: checkIns,
            activePlan: activePlan,
            planHistory: planHistory
        )
        weekDayCards = Self.computeWeekDayCards(
            checkIns: checkIns
        )
        urgeTrend = Self.computeUrgeTrend(
            checkIns: checkIns,
            interventions: interventions
        )
    }

    // MARK: - Private computation methods

    private static func computeStreakMetrics(...) -> AdherenceStreakMetrics { ... }
    private static func computeAdherenceMonths(...) -> [AdherenceMonth] { ... }
    private static func computeWeekDays(...) -> [WeekDayState] { ... }
    private static func computeWeekDayCards(...) -> [WeekDayCardData] { ... }
    private static func computeUrgeTrend(...) -> [Double] { ... }
}
```

Screens read directly from StatsManager:

```swift
struct HomeView: View {
    @Environment(StatsManager.self) var statsManager
    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager

    var body: some View {
        VStack {
            Text("\(statsManager.streakMetrics.current) day streak")

            ForEach(statsManager.weekDays) { day in
                dayDot(label: day.label, state: day.state)
            }
        }
    }
}

struct ProgressView: View {
    @Environment(StatsManager.self) var statsManager

    var body: some View {
        ScrollView {
            // use statsManager.adherenceMonths, statsManager.urgeTrend directly
        }
    }
}
```

### When to recalculate

StatsManager.recalculate() is called by:
- **Bootstrap** — on app start and foreground return
- **onDismiss** — after check-in, plan change, or urge intervention

---

## Shared Helpers

Utility logic that is used by 2+ Managers lives in `Shared/Extensions/`. Never duplicate logic across Managers — extract it.

Common examples:
- Date helpers (monday-of-week, week intervals, start-of-day)
- Calendar configuration (firstWeekday = 2)
- Formatting helpers

```swift
// Shared/Extensions/Date+Helpers.swift
extension Date {

    static func thisWeekMonday(now: Date = .now) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = calendar.startOfDay(for: now)
        return calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
    }

    static func lastWeekMonday(now: Date = .now) -> Date {
        Calendar.current.date(byAdding: .day, value: -7, to: thisWeekMonday(now: now))
            ?? thisWeekMonday(now: now)
    }
}
```

Rules:
- If 2+ files need the same logic, extract to Shared/Extensions/
- Managers call shared helpers, never reimplement them
- Keep helpers pure — no side effects, no state, just input → output

---

## Error Handling

Each Manager defines its own error enum. Errors flow upward: Store throws → Manager catches → Screen displays.

### Manager Errors

```swift
enum CheckInError: Error, LocalizedError {
    case alreadyCheckedInToday
    case invalidRating
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .alreadyCheckedInToday: "You already checked in today."
        case .invalidRating: "Rating must be between 1 and 10."
        case .saveFailed: "Could not save your check-in."
        case .loadFailed: "Could not load check-ins."
        }
    }
}
```

### Store — throws errors, never catches them

```swift
@MainActor
protocol CheckInStore {
    func fetchAll() throws -> [CheckInSnapshot]
    func save(_ snapshot: CheckInSnapshot) throws
    func delete(_ id: UUID) throws
}

@MainActor
final class SwiftDataCheckInStore: CheckInStore {
    private let context: ModelContext

    func fetchAll() throws -> [CheckInSnapshot] {
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: CheckInSnapshot) throws {
        let model = CheckIn(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
```

### Manager — catches errors, exposes error state

```swift
@MainActor @Observable
final class CheckInManager {
    private let store: CheckInStore

    var checkIns: [CheckInSnapshot] = []
    var error: CheckInError?

    func loadCheckIns() {
        do {
            checkIns = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func submitCheckIn(rating: Int) {
        guard rating >= 1 && rating <= 10 else {
            error = .invalidRating
            return
        }

        guard canCheckInToday else {
            error = .alreadyCheckedInToday
            return
        }

        do {
            let snapshot = CheckInSnapshot(date: .now, rating: rating)
            try store.save(snapshot)
            loadCheckIns()
        } catch {
            self.error = .saveFailed
        }
    }
}
```

### Screen — reads error state, displays it

```swift
struct CheckInView: View {
    @Environment(CheckInManager.self) var manager

    var body: some View {
        VStack {
            // content
        }
        .alert(
            "Error",
            isPresented: .init(
                get: { manager.error != nil },
                set: { if !$0 { manager.error = nil } }
            ),
            actions: { Button("OK") { manager.error = nil } },
            message: { Text(manager.error?.localizedDescription ?? "") }
        )
    }
}
```

### Error Handling by Layer

- Store → throws errors, never catches
- Manager → catches errors, sets error property, validates with guard
- Screen → reads manager.error, shows alerts

---

## Optionals

Strict rules for safe unwrapping. Never force unwrap.

```swift
// ✅ guard let — early exit, keeps code flat
func submitCheckIn(rating: Int) {
    guard let plan = activePlan else { return }
    guard rating >= 1 && rating <= 10 else {
        error = .invalidRating
        return
    }
}

// ✅ if let — when you need both branches
if let todayCheckIn = manager.todayCheckIn {
    CheckInDetailCard(checkIn: todayCheckIn)
} else {
    CheckInPromptCard()
}

// ✅ nil coalescing — for defaults
Text(manager.todayCheckIn?.rating.description ?? "–")

// ✅ Optional chaining
manager.todayCheckIn?.rating

// ❌ NEVER force unwrap
let checkIn = manager.todayCheckIn!  // NEVER
try! context.save()                   // NEVER
```

### Handling Nil State

The Manager exposes optionals as-is. It never fakes data or provides empty defaults to hide nil. The Screen decides how to handle nil visually.

Manager — expose the optional, use guard let in methods:

```swift
@MainActor @Observable
final class PlanManager {
    private let store: PlanStore

    var activePlan: PlanSnapshot?
    var error: PlanError?

    func loadPlan() {
        do {
            activePlan = try store.fetchActivePlan()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    // guard let when you need the value to proceed
    func updatePlan(newApps: Set<SocialApp>) {
        guard let current = activePlan else {
            error = .noPlanActive
            return
        }

        do {
            let updated = current.updating(selectedApps: newApps)
            try store.save(updated)
            loadPlan()
        } catch {
            self.error = .saveFailed
        }
    }
}
```

Screen — three patterns depending on the situation:

```swift
// 1. Two different UIs — use if let
if let plan = planManager.activePlan {
    PlanCard(plan: plan)
} else {
    CreatePlanPrompt()
}

// 2. Show or hide — use if let, no else
if let plan = planManager.activePlan {
    PlanCard(plan: plan)
}

// 3. Just need a value — use nil coalescing
Text(planManager.activePlan?.preset.name ?? "No plan set")
```

### Optionals by Layer

- Store → guard let, no force unwraps
- Manager → guard let for early exit and validation, expose optionals as-is
- Screen → if let for conditional UI, nil coalescing for defaults

---

## Snapshot Pattern

SwiftData @Model classes never reach the Screen. They are converted to immutable structs.

```swift
// SwiftData model (Store layer only)
@Model
final class CheckIn {
    var id: UUID
    var date: Date
    var rating: Int

    func toSnapshot() -> CheckInSnapshot {
        CheckInSnapshot(id: id, date: date, rating: rating)
    }
}

// Snapshot (Manager + Screen layers)
struct CheckInSnapshot: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let rating: Int
}
```

---

## App Entry Point

All Managers created once with @State, injected via .environment(). Managers take no init dependencies on other Managers — they receive data as method parameters at call sites. Bootstrap and refresh logic lives in OffApp, not in any Screen.

```swift
@main
struct OffApp: App {

    @Environment(\.scenePhase) var scenePhase

    @State private var appState: AppState
    @State private var onboardingManager: OnboardingManager
    @State private var attributeManager: AttributeManager
    @State private var planManager: PlanManager
    @State private var checkInManager: CheckInManager
    @State private var urgeManager: UrgeManager
    @State private var insightManager: InsightManager
    @State private var statsManager: StatsManager
    @State private var bootstrapManager: BootstrapManager

    init() {
        let config: BuildConfiguration
        #if MOCK
        config = .mock
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        _appState = State(initialValue: AppState())
        _onboardingManager = State(initialValue: OnboardingManager())
        _statsManager = State(initialValue: StatsManager())
        _bootstrapManager = State(initialValue: BootstrapManager())

        switch config {
        case .mock:
            _attributeManager = State(initialValue: AttributeManager(store: MockAttributeStore()))
            _planManager = State(initialValue: PlanManager(store: MockPlanStore()))
            _checkInManager = State(initialValue: CheckInManager(store: MockCheckInStore()))
            _urgeManager = State(initialValue: UrgeManager(store: MockUrgeStore()))
            _insightManager = State(initialValue: InsightManager(
                store: MockInsightStore(),
                aiService: MockAIService()
            ))

        case .dev, .prod:
            let schema = Schema([
                AttributeScores.self, Plan.self, CheckIn.self,
                UrgeIntervention.self, WeeklyInsight.self
            ])
            let modelConfig = ModelConfiguration("Off.store", schema: schema)
            let container = try! ModelContainer(for: schema, configurations: modelConfig)
            let context = container.mainContext

            _attributeManager = State(initialValue: AttributeManager(
                store: SwiftDataAttributeStore(context: context)
            ))
            _planManager = State(initialValue: PlanManager(
                store: SwiftDataPlanStore(context: context)
            ))
            _checkInManager = State(initialValue: CheckInManager(
                store: SwiftDataCheckInStore(context: context)
            ))
            _urgeManager = State(initialValue: UrgeManager(
                store: SwiftDataUrgeStore(context: context)
            ))
            _insightManager = State(initialValue: InsightManager(
                store: SwiftDataInsightStore(context: context),
                aiService: ClaudeAIService()
            ))
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .preferredColorScheme(.light)
                .environment(appState)
                .environment(onboardingManager)
                .environment(attributeManager)
                .environment(planManager)
                .environment(checkInManager)
                .environment(urgeManager)
                .environment(insightManager)
                .environment(statsManager)
                .environment(bootstrapManager)
                .task {
                    bootstrapManager.bootstrap(
                        planManager: planManager,
                        checkInManager: checkInManager,
                        attributeManager: attributeManager,
                        insightManager: insightManager,
                        urgeManager: urgeManager,
                        statsManager: statsManager
                    )
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    bootstrapManager.refresh(
                        planManager: planManager,
                        checkInManager: checkInManager,
                        attributeManager: attributeManager,
                        insightManager: insightManager,
                        urgeManager: urgeManager,
                        statsManager: statsManager
                    )
                }
        }
    }
}

enum BuildConfiguration {
    case mock, dev, prod
}
```

### Bootstrap & Refresh

App-level concerns (startup loading, foreground refresh) live in OffApp via a BootstrapManager — never in Screens. This keeps Screens purely presentational.

BootstrapManager coordinates startup sequencing across Managers. It receives Managers as method parameters (not stored references) because it needs to call methods and read state that changes mid-sequence (e.g. loadPlan() then read activePlan).

```swift
@MainActor @Observable
final class BootstrapManager {

    func bootstrap(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager,
        statsManager: StatsManager
    ) {
        planManager.loadPlan()
        attributeManager.loadScores()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        attributeManager.runWeeklyEvolutionIfNeeded(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
        insightManager.checkWeeklyInsightAvailability(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
    }

    func refresh(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager,
        statsManager: StatsManager
    ) {
        planManager.loadPlan()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        attributeManager.runWeeklyEvolutionIfNeeded(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
        insightManager.checkWeeklyInsightAvailability(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
    }
}
```

---

## Preview System

One PreviewContainer, one .withPreviewManagers() modifier. PreviewContainer wires Managers with mock Stores and runs the same bootstrap as the real app. This guarantees previews display data without Screens needing their own .task load calls.

```swift
@MainActor
struct PreviewContainer {
    static let appState = AppState()
    static let onboardingManager = OnboardingManager()
    static let attributeManager = AttributeManager(store: MockAttributeStore())
    static let planManager = PlanManager(store: MockPlanStore())
    static let checkInManager = CheckInManager(store: MockCheckInStore())
    static let urgeManager = UrgeManager(store: MockUrgeStore())
    static let insightManager = InsightManager(store: MockInsightStore(), aiService: MockAIService())
    static let statsManager = StatsManager()
    static let bootstrapManager = BootstrapManager()

    static func bootstrap() {
        bootstrapManager.bootstrap(
            planManager: planManager,
            checkInManager: checkInManager,
            attributeManager: attributeManager,
            insightManager: insightManager,
            urgeManager: urgeManager,
            statsManager: statsManager
        )
    }
}

extension View {
    func withPreviewManagers() -> some View {
        self
            .environment(PreviewContainer.appState)
            .environment(PreviewContainer.onboardingManager)
            .environment(PreviewContainer.attributeManager)
            .environment(PreviewContainer.planManager)
            .environment(PreviewContainer.checkInManager)
            .environment(PreviewContainer.urgeManager)
            .environment(PreviewContainer.insightManager)
            .environment(PreviewContainer.statsManager)
            .environment(PreviewContainer.bootstrapManager)
            .task { PreviewContainer.bootstrap() }
    }
}

#Preview {
    HomeView()
        .withPreviewManagers()
}
```

---

## Folder Structure

```
App/
  OffApp.swift                        ← entry point, creates and injects managers
  AppState.swift                      ← global UI state (tab bar, onboarding)
  AppView.swift                       ← root view (onboarding vs tabbar)
  AppViewBuilder.swift                ← generic transition builder

Screens/                              ← ALL views, presentation only
  Home/
    HomeView.swift
    HomeView+Helpers.swift
  TabBar/
    TabBarView.swift
  CheckIn/
    CheckInView.swift
    CheckInView+Helpers.swift
  Urge/
    UrgeInterventionView.swift
  Insight/
    WeeklyInsightView.swift
    WeeklyInsightDetailView.swift
  Progress/
    ProgressView.swift
  Settings/
    SettingsView.swift
  Onboarding/
    OnboardingView.swift
    OnboardingFlow.swift

Components/                           ← Reusable views used in 2+ screens
  CheckInRow.swift
  StreakCard.swift
  RatingBadge.swift

Managers/                              ← ALL logic + data, flat per manager
  CheckIn/
    CheckInManager.swift
    CheckInStore.swift
    CheckIn.swift                     ← @Model
    CheckInSnapshot.swift
    CheckInSnapshot+Samples.swift
    MockCheckInStore.swift
    AttributeRating.swift
    ControlRating.swift
  Plan/
    PlanManager.swift
    PlanStore.swift
    Plan.swift                        ← @Model
    PlanSnapshot.swift
    PlanSnapshot+Samples.swift
    MockPlanStore.swift
    PlanAdherence.swift
    TimeBoundary.swift
  Attribute/
    AttributeManager.swift
    AttributeStore.swift
    AttributeScores.swift             ← @Model
    AttributeScoresSnapshot.swift
    MockAttributeStore.swift
  Urge/
    UrgeManager.swift
    UrgeStore.swift
    UrgeIntervention.swift            ← @Model
    UrgeSnapshot.swift
    UrgeSnapshot+Samples.swift
    MockUrgeStore.swift
    UrgeLevel.swift
  Insight/
    InsightManager.swift
    InsightStore.swift
    WeeklyInsight.swift               ← @Model
    InsightSnapshot.swift
    InsightSnapshot+Samples.swift
    MockInsightStore.swift
    ClaudeAIService.swift
    MockAIService.swift
  Onboarding/
    OnboardingManager.swift           ← ephemeral flow state, no Store
  Stats/
    StatsManager.swift                ← derived state from multiple managers, no Store
  Bootstrap/
    BootstrapManager.swift            ← app startup + refresh sequencing, no Store

Shared/
  Preview/
    PreviewContainer.swift
  Extensions/
    Date+Helpers.swift
    Color+Theme.swift
  Theme/
    Typography.swift
    Spacing.swift
```

---

## Rules Summary

- Screen never touches SwiftData → Screen only sees Snapshots
- Screen holds only local UI state → @State for UI-only concerns (selection, toggles, search text)
- Screen never holds cross-manager derived state → read from StatsManager via @Environment
- State lives in Managers → data, computed properties, business logic
- Manager owns a topic → one Manager per topic, Store is optional
- Manager never imports SwiftUI → Manager is plain @MainActor @Observable
- Store has no state → Protocol only has throwing functions
- One source of truth per topic → One Manager, multiple Screens read it
- Cross-manager derived state → StatsManager, not duplicated in views
- Managers never reference other Managers → receive external data as method parameters
- Bootstrap and refresh live in OffApp via BootstrapManager → never in Screens
- Screens never call Manager load methods in .task → bootstrap handles it
- Managers reload after every save → save to Store, then call load method, never update state in-place
- Error flow → Store throws, Manager catches and sets error property, Screen displays
- No force unwraps → guard let, if let, nil coalescing only
- Managers survive re-renders → @State in OffApp
- MOCK/DEV/PROD switching → Compiler flags in OffApp.init()
- Previews work instantly → PreviewContainer + .withPreviewManagers() runs same bootstrap as real app
- Screens stay dumb → Screens read Managers and call methods, never orchestrate logic
- Large Views → Split into computed properties first, then private child Views, then Components/
- Components/ → Only for Views reused in 2+ screens
- Flat folders → Subfolder only when 10+ files
- No duplicated logic → if 2+ files need it, extract to Shared/Extensions/
- Need to change looks? → Screens/
- Need to change logic? → Managers/
- Need to change data source? → Managers/ → Store file
- No unit tests. This project does not use XCTest, test targets, or test-driven abstractions—validation is done via previews, mocks, and real usage only.
