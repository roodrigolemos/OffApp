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

When a Screen presents another Screen that changes data, the presenting Screen reloads the affected Managers and recalculates derived state in `onDismiss`. This is the only place Screens call Manager load methods — never in `.task`.

```swift
struct ItemListView: View {
    @Environment(ItemManager.self) var itemManager
    @Environment(StatsManager.self) var statsManager

    @State private var showCreateItem = false

    var body: some View {
        List(itemManager.items) { item in
            ItemRow(item: item)
        }
        .fullScreenCover(isPresented: $showCreateItem, onDismiss: {
            itemManager.loadItems()
            statsManager.recalculate(items: itemManager.items)
        }) {
            CreateItemView()
        }
    }
}
```

Rules:
- Only reload the Manager whose data changed
- Always recalculate derived state after any data change that affects it
- Bootstrap handles initial loading — onDismiss handles mid-session changes

### View State Rule

Screens hold LOCAL UI state — things that only matter to that specific screen. They do NOT hold manager state (data, business logic, anything shared).

If it dies when the screen disappears and nobody cares, it's @State in the View.
If it needs to survive across screens or be shared, it's in the Manager.

```swift
struct ItemDetailView: View {
    @Environment(ItemManager.self) var manager

    // ✅ Local UI state — belongs in the View
    @State private var selectedRating: Int = 5
    @State private var showConfirmation: Bool = false
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""

    // ❌ Manager state — belongs in the Manager
    // @State private var items: [ItemSnapshot] = []

    // ❌ Cross-manager derived state — belongs in a dedicated Manager
    // @State private var streakCount: Int = 0

    var body: some View {
        VStack {
            // content
            Button("Save") {
                manager.save(rating: selectedRating)
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
// ItemDetailView.swift
struct ItemDetailView: View {
    @Environment(ItemManager.self) var manager

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
private extension ItemDetailView {

    var headerSection: some View {
        VStack(spacing: 8) {
            Text("Item Detail")
                .font(.title)
            Text("Rate this item")
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
            ForEach(manager.items.prefix(5)) { item in
                ItemRow(item: item)
            }
        }
    }

    var submitButton: some View {
        Button("Submit") {
            manager.save(rating: selectedRating)
            showConfirmation = true
        }
    }
}
```

When a section is complex and needs its own state, extract a private child View in the same file:

```swift
// Still in ItemDetailView.swift
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
// Components/ItemRow.swift
struct ItemRow: View {
    let item: ItemSnapshot

    var body: some View {
        HStack {
            Text(item.date.formatted(.dateTime.month().day()))
            Spacer()
            Text("\(item.rating)/10")
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

### Manager with Store (persisted data)

```swift
@MainActor @Observable
final class ItemManager {
    private let store: ItemStore

    var items: [ItemSnapshot] = []
    var error: ItemError?

    var hasItemToday: Bool {
        items.contains { Calendar.current.isDateInToday($0.date) }
    }

    init(store: ItemStore) {
        self.store = store
    }

    func loadItems() {
        do {
            items = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func save(_ snapshot: ItemSnapshot) {
        do {
            try store.save(snapshot)
            loadItems()
        } catch {
            self.error = .saveFailed
        }
    }
}
```

### Manager without Store (derived or ephemeral state)

When multiple Screens need the same derived state computed from other Managers, put it in a dedicated Manager. Screens read via @Environment — no @State for derived data, no duplication across views.

```swift
@MainActor @Observable
final class StatsManager {

    var totalCount: Int = 0
    var streakDays: Int = 0
    var recentTrend: [Double] = []

    func recalculate(
        items: [ItemSnapshot],
        categories: [CategorySnapshot]
    ) {
        totalCount = Self.computeTotalCount(items: items)
        streakDays = Self.computeStreak(items: items, categories: categories)
        recentTrend = Self.computeTrend(items: items)
    }

    // MARK: - Private computation methods

    private static func computeTotalCount(items: [ItemSnapshot]) -> Int { ... }
    private static func computeStreak(items: [ItemSnapshot], categories: [CategorySnapshot]) -> Int { ... }
    private static func computeTrend(items: [ItemSnapshot]) -> [Double] { ... }
}
```

Screens read directly:

```swift
struct DashboardView: View {
    @Environment(StatsManager.self) var statsManager

    var body: some View {
        VStack {
            Text("\(statsManager.streakDays) day streak")
            TrendChart(data: statsManager.recentTrend)
        }
    }
}
```

recalculate() is called by:
- **Bootstrap** — on app start and foreground return
- **onDismiss** — after user actions that change data

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
protocol ItemStore {
    func fetchAll() throws -> [ItemSnapshot]
    func save(_ snapshot: ItemSnapshot) throws
    func delete(_ id: UUID) throws
}

@MainActor
final class SwiftDataItemStore: ItemStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [ItemSnapshot] {
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: ItemSnapshot) throws {
        let model = Item(from: snapshot)
        context.insert(model)
        try context.save()
    }

    func delete(_ id: UUID) throws {
        // fetch and delete
    }
}
```

---

## Shared Helpers

Utility logic that is used by 2+ Managers lives in `Shared/Extensions/`. Never duplicate logic across Managers — extract it.

Common examples:
- Date helpers (monday-of-week, week intervals, start-of-day)
- Calendar configuration
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
enum ItemError: Error, LocalizedError {
    case duplicateEntry
    case invalidRating
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .duplicateEntry: "An entry already exists for today."
        case .invalidRating: "Rating must be between 1 and 10."
        case .saveFailed: "Could not save."
        case .loadFailed: "Could not load data."
        }
    }
}
```

### Store — throws errors, never catches them

```swift
@MainActor
protocol ItemStore {
    func fetchAll() throws -> [ItemSnapshot]
    func save(_ snapshot: ItemSnapshot) throws
    func delete(_ id: UUID) throws
}

@MainActor
final class SwiftDataItemStore: ItemStore {
    private let context: ModelContext

    func fetchAll() throws -> [ItemSnapshot] {
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: ItemSnapshot) throws {
        let model = Item(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
```

### Manager — catches errors, exposes error state

```swift
@MainActor @Observable
final class ItemManager {
    private let store: ItemStore

    var items: [ItemSnapshot] = []
    var error: ItemError?

    func loadItems() {
        do {
            items = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func save(rating: Int) {
        guard rating >= 1 && rating <= 10 else {
            error = .invalidRating
            return
        }

        guard !hasItemToday else {
            error = .duplicateEntry
            return
        }

        do {
            let snapshot = ItemSnapshot(date: .now, rating: rating)
            try store.save(snapshot)
            loadItems()
        } catch {
            self.error = .saveFailed
        }
    }
}
```

### Screen — reads error state, displays it

```swift
struct ItemView: View {
    @Environment(ItemManager.self) var manager

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
func save(rating: Int) {
    guard let active = activeItem else { return }
    guard rating >= 1 && rating <= 10 else {
        error = .invalidRating
        return
    }
}

// ✅ if let — when you need both branches
if let item = manager.activeItem {
    ItemDetailCard(item: item)
} else {
    EmptyStatePrompt()
}

// ✅ nil coalescing — for defaults
Text(manager.activeItem?.name ?? "–")

// ✅ Optional chaining
manager.activeItem?.rating

// ❌ NEVER force unwrap
let item = manager.activeItem!  // NEVER
try! context.save()              // NEVER
```

### Handling Nil State

The Manager exposes optionals as-is. It never fakes data or provides empty defaults to hide nil. The Screen decides how to handle nil visually.

Manager — expose the optional, use guard let in methods:

```swift
@MainActor @Observable
final class CategoryManager {
    private let store: CategoryStore

    var activeCategory: CategorySnapshot?
    var error: CategoryError?

    func loadCategory() {
        do {
            activeCategory = try store.fetchActive()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    // guard let when you need the value to proceed
    func updateCategory(name: String) {
        guard let current = activeCategory else {
            error = .noCategoryActive
            return
        }

        do {
            let updated = current.updating(name: name)
            try store.save(updated)
            loadCategory()
        } catch {
            self.error = .saveFailed
        }
    }
}
```

Screen — three patterns depending on the situation:

```swift
// 1. Two different UIs — use if let
if let category = categoryManager.activeCategory {
    CategoryCard(category: category)
} else {
    CreateCategoryPrompt()
}

// 2. Show or hide — use if let, no else
if let category = categoryManager.activeCategory {
    CategoryCard(category: category)
}

// 3. Just need a value — use nil coalescing
Text(categoryManager.activeCategory?.name ?? "No category set")
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
final class Item {
    var id: UUID
    var date: Date
    var rating: Int

    func toSnapshot() -> ItemSnapshot {
        ItemSnapshot(id: id, date: date, rating: rating)
    }
}

// Snapshot (Manager + Screen layers)
struct ItemSnapshot: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let rating: Int
}
```

---

## App Entry Point

All Managers created once with @State, injected via .environment(). Managers take no init dependencies on other Managers — they receive data as method parameters at call sites. Bootstrap and refresh logic lives in the App struct, not in any Screen.

```swift
@main
struct MyApp: App {

    @Environment(\.scenePhase) var scenePhase

    @State private var appState: AppState
    @State private var itemManager: ItemManager
    @State private var categoryManager: CategoryManager
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
        _statsManager = State(initialValue: StatsManager())
        _bootstrapManager = State(initialValue: BootstrapManager())

        switch config {
        case .mock:
            _itemManager = State(initialValue: ItemManager(store: MockItemStore()))
            _categoryManager = State(initialValue: CategoryManager(store: MockCategoryStore()))

        case .dev, .prod:
            let schema = Schema([Item.self, Category.self])
            let modelConfig = ModelConfiguration("MyApp.store", schema: schema)
            let container = try! ModelContainer(for: schema, configurations: modelConfig)
            let context = container.mainContext

            _itemManager = State(initialValue: ItemManager(
                store: SwiftDataItemStore(context: context)
            ))
            _categoryManager = State(initialValue: CategoryManager(
                store: SwiftDataCategoryStore(context: context)
            ))
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(appState)
                .environment(itemManager)
                .environment(categoryManager)
                .environment(statsManager)
                .environment(bootstrapManager)
                .task {
                    bootstrapManager.bootstrap(
                        itemManager: itemManager,
                        categoryManager: categoryManager,
                        statsManager: statsManager
                    )
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    bootstrapManager.refresh(
                        itemManager: itemManager,
                        categoryManager: categoryManager,
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

App-level concerns (startup loading, foreground refresh) live in the App struct via a BootstrapManager — never in Screens. This keeps Screens purely presentational.

BootstrapManager coordinates startup sequencing across Managers. It receives Managers as method parameters (not stored references) because it needs to call methods and read state that changes mid-sequence (e.g. loadCategory() then read activeCategory).

```swift
@MainActor @Observable
final class BootstrapManager {

    func bootstrap(
        itemManager: ItemManager,
        categoryManager: CategoryManager,
        statsManager: StatsManager
    ) {
        categoryManager.loadCategory()
        itemManager.loadItems()
        statsManager.recalculate(
            items: itemManager.items,
            categories: [categoryManager.activeCategory].compactMap { $0 }
        )
    }

    func refresh(
        itemManager: ItemManager,
        categoryManager: CategoryManager,
        statsManager: StatsManager
    ) {
        categoryManager.loadCategory()
        itemManager.loadItems()
        statsManager.recalculate(
            items: itemManager.items,
            categories: [categoryManager.activeCategory].compactMap { $0 }
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
    static let itemManager = ItemManager(store: MockItemStore())
    static let categoryManager = CategoryManager(store: MockCategoryStore())
    static let statsManager = StatsManager()
    static let bootstrapManager = BootstrapManager()

    static func bootstrap() {
        bootstrapManager.bootstrap(
            itemManager: itemManager,
            categoryManager: categoryManager,
            statsManager: statsManager
        )
    }
}

extension View {
    func withPreviewManagers() -> some View {
        self
            .environment(PreviewContainer.appState)
            .environment(PreviewContainer.itemManager)
            .environment(PreviewContainer.categoryManager)
            .environment(PreviewContainer.statsManager)
            .environment(PreviewContainer.bootstrapManager)
            .task { PreviewContainer.bootstrap() }
    }
}

#Preview {
    DashboardView()
        .withPreviewManagers()
}
```

---

## Folder Structure

```
App/
  MyApp.swift                         ← entry point, creates and injects managers
  AppState.swift                      ← global UI state
  AppView.swift                       ← root view

Screens/                              ← ALL views, presentation only
  Dashboard/
    DashboardView.swift
    DashboardView+Helpers.swift
  Detail/
    ItemDetailView.swift
  Settings/
    SettingsView.swift

Components/                           ← Reusable views used in 2+ screens
  ItemRow.swift
  StatCard.swift

Managers/                             ← ALL logic + data, flat per manager
  Item/
    ItemManager.swift
    ItemStore.swift
    Item.swift                        ← @Model
    ItemSnapshot.swift
    ItemSnapshot+Samples.swift
    MockItemStore.swift
  Category/
    CategoryManager.swift
    CategoryStore.swift
    Category.swift                    ← @Model
    CategorySnapshot.swift
    MockCategoryStore.swift
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
- Screen never holds cross-manager derived state → read from dedicated Manager via @Environment
- State lives in Managers → data, computed properties, business logic
- Manager owns a topic → one Manager per topic, Store is optional
- Manager never imports SwiftUI → Manager is plain @MainActor @Observable
- Store has no state → Protocol only has throwing functions
- One source of truth per topic → One Manager, multiple Screens read it
- Cross-manager derived state → dedicated Manager, not duplicated in views
- Managers never reference other Managers → receive external data as method parameters
- Bootstrap and refresh live in App struct via BootstrapManager → never in Screens
- Screens never call Manager load methods in .task → bootstrap handles it
- Managers reload after every save → save to Store, then call load method, never update state in-place
- Error flow → Store throws, Manager catches and sets error property, Screen displays
- No force unwraps → guard let, if let, nil coalescing only
- Managers survive re-renders → @State in App struct
- MOCK/DEV/PROD switching → Compiler flags in App.init()
- Previews work instantly → PreviewContainer + .withPreviewManagers() runs same bootstrap as real app
- Screens stay dumb → Screens read Managers and call methods, never orchestrate logic
- Large Views → Split into computed properties first, then private child Views, then Components/
- Components/ → Only for Views reused in 2+ screens
- Flat folders → Subfolder only when 10+ files
- No duplicated logic → if 2+ files need it, extract to Shared/Extensions/
- Need to change looks? → Screens/
- Need to change logic? → Managers/
- Need to change data source? → Managers/ → Store file
