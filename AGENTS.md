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
- Never contains business logic
- Reads state from Manager via @Environment
- Calls Manager methods for user actions
- Uses .task to trigger initial data loading
- CAN hold local UI state via @State (see below)

### View State Rule

Screens hold LOCAL UI state — things that only matter to that specific screen. They do NOT hold domain state (data, business logic, anything shared).

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

    // ❌ Domain state — belongs in the Manager
    // @State private var checkIns: [CheckInSnapshot] = []
    // @State private var currentStreak: Int = 0

    var body: some View {
        VStack {
            Slider(value: .init(
                get: { Double(selectedRating) },
                set: { selectedRating = Int($0) }
            ), in: 1...10)

            Button("Submit") {
                Task {
                    await manager.submitCheckIn(rating: selectedRating)
                    showConfirmation = true
                }
            }
        }
        .alert("Saved!", isPresented: $showConfirmation) { }
        .task { await manager.loadCheckIns() }
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
        .task { await manager.loadCheckIns() }
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
            Task {
                await manager.submitCheckIn(rating: selectedRating)
                showConfirmation = true
            }
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

What it does: Owns all business logic and is the single source of truth for a domain. A Manager always owns data with a lifecycle (create, read, update, delete) and delegates persistence to a Store.

Rules:
- @MainActor @Observable
- Never imports SwiftUI
- One Manager per domain, not per screen
- Owns state that Screens read
- Contains computed properties, validation, transformations
- Delegates all data operations to the Store
- Exposes only Snapshot structs, never @Model objects
- Never holds references to other Managers — receives external data as method parameters
- If the logic only computes derived display state from other domains, it's a Calculator, not a Manager

```swift
@MainActor @Observable
final class CheckInManager {
    private let store: CheckInStore

    var checkIns: [CheckInSnapshot] = []

    var todayCheckIn: CheckInSnapshot? {
        checkIns.first { Calendar.current.isDateInToday($0.date) }
    }

    var canCheckInToday: Bool { todayCheckIn == nil }

    init(store: CheckInStore) {
        self.store = store
    }

    func loadCheckIns() async {
        checkIns = await store.fetchAll()
    }

    func submitCheckIn(rating: Int) async {
        guard canCheckInToday else { return }
        let snapshot = CheckInSnapshot(date: .now, rating: rating)
        await store.save(snapshot)
        await loadCheckIns()
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
    func fetchAll() async -> [CheckInSnapshot]
    func save(_ snapshot: CheckInSnapshot) async
    func delete(_ id: UUID) async
}

@MainActor
final class SwiftDataCheckInStore: CheckInStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async -> [CheckInSnapshot] {
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = (try? context.fetch(descriptor)) ?? []
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: CheckInSnapshot) async {
        let model = CheckIn(from: snapshot)
        context.insert(model)
        try? context.save()
    }

    func delete(_ id: UUID) async {
        // fetch and delete
    }
}
```

---

## What is a Domain

A domain is a real concept in the app that has its own data, business rules, and lifecycle. It's something the user creates, modifies, or deletes — a thing that exists independently.

A domain has:
- **Data it owns** — persisted state (check-ins, plans, scores)
- **Business rules** — validation, constraints, state transitions
- **A lifecycle** — it's created, read, updated, deleted
- **A Manager** — single source of truth for the domain
- **A Store** — persistence layer (SwiftData, API, mock)
- **Snapshots** — immutable structs exposed to Screens

Current domains in Off:
- **Plan** — what the user committed to do (apps, schedule, days)
- **CheckIn** — daily self-reports (ratings, adherence)
- **Urge** — intervention sessions (timestamps, responses, outcomes)
- **Insight** — weekly AI feedback (narrative text, availability)
- **Attribute** — the six wellness scores (evolution, momentum)

### What is NOT a Domain

Not everything that computes or holds state is a domain. If the logic only **reads** from other domains to produce derived display state — and never creates, modifies, or persists its own data — it's not a domain. It's a **Calculator**.

Test: Does the user ever say "I want to create/edit/delete my [thing]"? If no, it's not a domain.

Examples of things that are NOT domains:
- Streak calculations (derived from check-ins + plans)
- Adherence calendars (derived from check-ins + plans)
- Weekly day cards (derived from check-ins + plans)
- Urge trend charts (derived from check-ins + interventions)

## Calculators

Calculators are stateless enums with static functions that compute derived state from multiple domains. They have no Store, no persistence, no @Observable state. Screens call them and hold results in @State.

### When to Use a Calculator

Use a Calculator when:
- The logic reads from 2+ domains to produce display data
- It doesn't persist anything — purely derived
- The user never creates, modifies, or deletes the output

Use a Manager when:
- It owns data with a lifecycle (create, read, update, delete)
- It has a Store for persistence
- It has validation and business rules that guard mutations

### Structure

```swift
enum StatsCalculator {

    static func streakMetrics(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        now: Date = .now
    ) -> AdherenceStreakMetrics {
        let history = planHistoryEntries(plans: planHistory, fallbackPlan: activePlan)
        // ... calculation logic
    }

    static func adherenceMonths(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        now: Date = .now
    ) -> [AdherenceMonth] {
        // ... calculation logic
    }

    static func weekDays(
        checkIns: [CheckInSnapshot],
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        now: Date = .now
    ) -> [WeekDayState] {
        // ... calculation logic
    }

    static func urgeTrend(
        checkIns: [CheckInSnapshot],
        interventions: [UrgeSnapshot],
        now: Date = .now
    ) -> [Double] {
        // ... calculation logic
    }
}
```

The Screen calls static functions and holds results in @State:

```swift
struct ProgressView: View {
    @Environment(CheckInManager.self) var checkInManager
    @Environment(PlanManager.self) var planManager
    @Environment(AttributeManager.self) var attributeManager
    @Environment(UrgeManager.self) var urgeManager

    @State private var adherenceMonths: [AdherenceMonth] = []
    @State private var streakMetrics = AdherenceStreakMetrics(current: 0, bestEver: 0, totalDaysFollowed: 0)
    @State private var urgeTrend: [Double] = []

    var body: some View {
        ScrollView {
            // use @State values directly
        }
        .task {
            adherenceMonths = StatsCalculator.adherenceMonths(
                checkIns: checkInManager.checkIns,
                activePlan: planManager.activePlan,
                planHistory: planManager.planHistory
            )
            streakMetrics = StatsCalculator.streakMetrics(
                checkIns: checkInManager.checkIns,
                activePlan: planManager.activePlan,
                planHistory: planManager.planHistory
            )
            urgeTrend = StatsCalculator.urgeTrend(
                checkIns: checkInManager.checkIns,
                interventions: urgeManager.interventions
            )
        }
    }
}
```

### Rules

- Stateless enum with static functions — no @Observable, no stored properties
- Pure computation — receives snapshots as parameters, returns results
- No Store, no persistence, no lifecycle
- Lives in Shared/ not Domains/ — it's a utility, not a domain
- Screens hold results in @State — the data dies when the screen disappears
- Multiple Screens can call the same Calculator functions (HomeView uses streakMetrics, ProgressView uses everything)

---

## Shared Helpers

Utility logic that is used by 2+ Managers or by both a Manager and a Calculator lives in `Shared/Extensions/`. Never duplicate logic across domains — extract it.

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
- Managers and Calculators call shared helpers, never reimplement them
- Keep helpers pure — no side effects, no state, just input → output

---

## Error Handling

Each domain defines its own error enum. Errors flow upward: Store throws → Manager catches → Screen displays.

### Domain Errors

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
            error = nil
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
        .task { manager.loadCheckIns() }
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
            activePlan = updated
            error = nil
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

All Managers created once with @State, injected via .environment(). Cross-domain Managers take no init dependencies — they receive data as method parameters at call sites. Bootstrap and refresh logic lives in OffApp, not in any Screen.

```swift
@main
struct OffApp: App {

    @Environment(\.scenePhase) var scenePhase

    @State private var appState: AppState
    @State private var checkInManager: CheckInManager
    @State private var planManager: PlanManager
    @State private var urgeManager: UrgeManager
    @State private var insightManager: InsightManager
    @State private var attributeManager: AttributeManager
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
        _bootstrapManager = State(initialValue: BootstrapManager())

        switch config {
        case .mock:
            _checkInManager = State(initialValue: CheckInManager(store: MockCheckInStore()))
            _planManager = State(initialValue: PlanManager(store: MockPlanStore()))
            _attributeManager = State(initialValue: AttributeManager(store: MockAttributeStore()))
            _urgeManager = State(initialValue: UrgeManager(store: MockUrgeStore()))
            _insightManager = State(initialValue: InsightManager(
                store: MockInsightStore(),
                aiStore: MockAIStore()
            ))

        case .dev, .prod:
            let schema = Schema([
                CheckIn.self, Plan.self, TimeWindow.self,
                UrgeIntervention.self, WeeklyInsight.self
            ])
            let modelConfig = ModelConfiguration("Off.store", schema: schema)
            let container = try! ModelContainer(for: schema, configurations: modelConfig)
            let context = container.mainContext

            _checkInManager = State(initialValue: CheckInManager(
                store: SwiftDataCheckInStore(context: context)
            ))
            _planManager = State(initialValue: PlanManager(
                store: SwiftDataPlanStore(context: context)
            ))
            _attributeManager = State(initialValue: AttributeManager(
                store: SwiftDataAttributeStore(context: context)
            ))
            _urgeManager = State(initialValue: UrgeManager(
                store: SwiftDataUrgeStore(context: context)
            ))
            _insightManager = State(initialValue: InsightManager(
                store: SwiftDataInsightStore(context: context),
                aiStore: ClaudeAIStore()
            ))
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .preferredColorScheme(.light)
                .environment(appState)
                .environment(checkInManager)
                .environment(planManager)
                .environment(attributeManager)
                .environment(urgeManager)
                .environment(insightManager)
                .environment(bootstrapManager)
                .task {
                    bootstrapManager.bootstrap(
                        planManager: planManager,
                        checkInManager: checkInManager,
                        attributeManager: attributeManager,
                        insightManager: insightManager
                    )
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    bootstrapManager.refresh(
                        planManager: planManager,
                        checkInManager: checkInManager,
                        attributeManager: attributeManager,
                        insightManager: insightManager
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

BootstrapManager is a cross-domain Manager that coordinates sequencing across domains. It receives Managers as parameters because it needs to call methods and read state that changes mid-sequence (e.g. loadPlan() then read activePlan). This is the one exception where passing whole Managers instead of snapshots is valid.

```swift
@MainActor @Observable
final class BootstrapManager {

    func bootstrap(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager
    ) {
        planManager.loadPlan()
        attributeManager.loadScores()
        checkInManager.boot(
            plan: planManager.activePlan,
            planHistory: planManager.planHistory
        )
        attributeManager.runWeeklyEvolutionIfNeeded(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
        insightManager.checkWeeklyInsightAvailability(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
    }

    func refresh(
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager
    ) {
        checkInManager.loadCheckIns()
        checkInManager.boot(
            plan: planManager.activePlan,
            planHistory: planManager.planHistory
        )
        attributeManager.runWeeklyEvolutionIfNeeded(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
        insightManager.checkWeeklyInsightAvailability(
            plan: planManager.activePlan,
            checkIns: checkInManager.checkIns
        )
    }
}
```

---

## Preview System

One PreviewContainer, one .withPreviewManagers() modifier. PreviewContainer only wires Managers with mock Stores — it does not call any loading methods. Mock Stores provide seed data through their initializers, so previews render immediately without needing .task to fire. The rule "Screens handle their own loading via .task" applies to the real app flow, not previews.

```swift
@MainActor
struct PreviewContainer {
    static let appState = AppState()
    static let checkInManager = CheckInManager(store: MockCheckInStore())
    static let planManager = PlanManager(store: MockPlanStore())
    static let attributeManager = AttributeManager(store: MockAttributeStore())
    static let urgeManager = UrgeManager(store: MockUrgeStore())
    static let insightManager = InsightManager(
        store: MockInsightStore(),
        aiStore: MockAIStore()
    )
    static let bootstrapManager = BootstrapManager()
}

extension View {
    func withPreviewManagers() -> some View {
        self
            .environment(PreviewContainer.appState)
            .environment(PreviewContainer.checkInManager)
            .environment(PreviewContainer.planManager)
            .environment(PreviewContainer.attributeManager)
            .environment(PreviewContainer.urgeManager)
            .environment(PreviewContainer.insightManager)
            .environment(PreviewContainer.bootstrapManager)
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

Domains/                              ← ALL logic + data, flat per domain
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
    Plan.swift
    TimeWindow.swift                  ← @Model
    PlanSnapshot.swift
    PlanSnapshot+Samples.swift
    MockPlanStore.swift
    PlanAdherence.swift
    TimeBoundary.swift
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
    ClaudeAIStore.swift
    MockAIStore.swift
  Bootstrap/
    BootstrapManager.swift            ← app startup + refresh sequencing, no Store

Shared/
  StatsCalculator.swift               ← stateless cross-domain calculations (streaks, adherence, trends)
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
- Domain state lives in Manager → data, computed properties, business logic
- Manager never imports SwiftUI → Manager is plain @MainActor @Observable
- Store has no state → Protocol only has throwing functions
- One source of truth per domain → One Manager, multiple Screens read it
- Domains own data with a lifecycle → Manager + Store + Snapshots
- Cross-domain derived state → StatsCalculator (stateless enum), not a Manager
- Managers never reference other Managers → receive external data as method parameters
- Bootstrap and refresh live in OffApp via BootstrapManager → never in Screens
- Error flow → Store throws, Manager catches and sets error property, Screen displays
- No force unwraps → guard let, if let, nil coalescing only
- Managers survive re-renders → @State in OffApp
- MOCK/DEV/PROD switching → Compiler flags in OffApp.init()
- Previews work instantly → PreviewContainer + .withPreviewManagers()
- Screens handle their own loading → .task in each Screen, not in PreviewContainer
- Screens stay dumb → Screens call methods, never orchestrate logic
- Large Views → Split into computed properties first, then private child Views, then Components/
- Components/ → Only for Views reused in 2+ screens
- Flat folders → Subfolder only when 10+ files
- No duplicated logic → if 2+ files need it, extract to Shared/Extensions/
- Need to change looks? → Screens/
- Need to change logic? → Domains/
- Need to change data source? → Domains/ → Store file
- No unit tests. This project does not use XCTest, test targets, or test-driven abstractions—validation is done via previews, mocks, and real usage only.
