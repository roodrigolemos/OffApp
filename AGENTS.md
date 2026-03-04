# Architecture: Screen → Manager → Store

Screen (presentation) → Manager (business logic + state) → Store (data access)

This architecture must be followed strictly for all code.

---

# Screen (Presentation)

Purpose: UI only.

Rules:
- Never import SwiftData
- Never contain business logic, validation, or cross-manager calculations
- Read Manager state using `@Environment(Manager.self)`
- Call Manager methods for user actions
- Never call `load()` in `.task` (Bootstrap handles initial loading)
- When presenting a screen that modifies data, use `onDismiss` to reload data and recalculate derived state

Screen state:
- `@State` is allowed only for local UI concerns (toggles, tabs, sheet flags, search text, temporary UI state)
- Never store manager data in `@State`
- Never store shared or derived data in `@State`

onDismiss rule:
- Reload only the Manager whose data changed
- Recalculate derived Managers when necessary
- Bootstrap handles initial load
- onDismiss handles mid-session updates

---

# Manager (Logic + State)

Purpose: Single source of truth for one topic.

Rules:
- Must be `@MainActor @Observable`
- Never import SwiftUI
- Own state that Screens read
- Handle validation, computed properties, and transformations
- Expose Snapshot structs only
- Never expose `@Model` objects
- Never hold references to other Managers

If a Manager needs data from another Manager, it must receive that data through method parameters.

Managers with Store:
- Store performs all CRUD operations
- After save or delete, call `load()`
- Never update arrays or state manually after saving

Correct flow:
save → store.save() → load()

Managers without Store:
Used for derived or aggregated state such as streaks, statistics, or trends.

Derived managers expose:
`recalculate(...)`

`recalculate()` is called by:
- Bootstrap
- onDismiss after user changes data

---

# Store (Data Access)

Purpose: Pure data access layer.

Rules:
- Protocol based
- `@MainActor`
- Stateless (no cached properties or stored state)
- Converts `@Model` objects to Snapshot structs
- Throws errors
- Never catches errors

Store implementations may represent:
- SwiftData
- API
- Mock data

---

# Snapshot Rule

`@Model` objects never reach Managers or Screens.

Conversion happens inside the Store.

Flow:
`@Model → Snapshot → Manager → Screen`

Snapshots must be:
- struct
- immutable
- safe for UI

---

# Error Flow

Error handling follows strict layering.

Store:
throws errors

Manager:
catches errors and sets `manager.error`

Screen:
observes `manager.error` and displays UI (alert, toast, etc.)

Each Manager defines its own error enum.

---

# Optionals

Never use:
- force unwrap `!`
- `try!`

Allowed patterns:
- `guard let`
- `if let`
- optional chaining
- nil coalescing `??`

Managers expose optionals as-is.  
Screens decide how to display nil states.

---

# App Bootstrap

Managers are created once in the App using `@State`.

Example:
`@State private var itemManager`
`@State private var statsManager`

Managers are injected using `.environment(...)`.

Startup loading and lifecycle refresh are handled by a `BootstrapManager`.

Screens must never perform initial loading.

---

# Shared Helpers

Logic used in two or more places must live in:

`Shared/Extensions/`

Rules:
- pure functions
- no side effects
- no state

Examples:
- date helpers
- formatting helpers
- calendar utilities

---

# Folder Structure

App/

Screens/

Components/ (views reused in two or more screens)

Managers/

Shared/

---

# Core Principles

- Screens are dumb
- Managers are the single source of truth
- Stores are pure data access
- Snapshots isolate UI from persistence
- Bootstrap handles lifecycle loading
- Logic duplication is not allowed
- No digits in identifiers or filenames — spell numbers out (e.g., seven, six)
