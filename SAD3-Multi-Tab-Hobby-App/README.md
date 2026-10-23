# SAD3 Multi-Tab Hobby App

Build Home, Schedule and Favorites tabs that share an activity selection.
The starter supplies three fictional activities and a Favorites placeholder.
Complete state, collections and navigation lessons first.

## Run one source role

Create an iOS App in Xcode using SwiftUI and deployment target iOS 17 or later.
Choose `starter/` or `solution/`, replace the generated App and ContentView
with that role's `MultiTabHobbyApp.swift` and `ContentView.swift`, and include
both in the target. Keep one `@main` App and one ContentView. Build and run on
an installed iPhone simulator. Record Xcode, Swift language mode, deployment
target, simulator model and OS. Keep starter edits separate from the reference.

The supplied records and system symbols need no account, personal data or
network service. A working preview does not establish a simulator launch.

## Separate peer destinations from a navigation path

TabView contains the peer Home, Schedule and Favorites destinations. Each has
its own NavigationStack. A Home detail route should stay inside that tab's
navigation context rather than replacing Schedule or becoming a fourth tab.

HobbyActivity groups an ID, title, day and symbol name. Home and Schedule read
the same array with different presentations. List uses each record's ID to
associate its row with that record. The supplied schedule is Photo Walk on
Tuesday, Sketch Session on Thursday and Community Meetup on Saturday. Change
one day and predict both screens before running.

The reference adds a summary property. Adding a nonoptional stored property
requires supplying it in every initializer.

## Share state above both consumers

Favorites is needed by Home's detail action and the Favorites tab. ContentView
is their common parent. One set of selected IDs can supply both:

```swift
@State private var favorites = Set<UUID>()

private var favoriteActivities: [HobbyActivity] {
    activities.filter { favorites.contains($0.id) }
}

private func toggleFavorite(_ activity: HobbyActivity) {
    if favorites.contains(activity.id) {
        favorites.remove(activity.id)
    } else {
        favorites.insert(activity.id)
    }
}
```

The filtered collection keeps the existing records and IDs. A separate count
or second favorite array would require synchronizing redundant state.
State is retained for a view's identity; preserve record IDs while switching
tabs and deriving results.

Pass the selected activity, membership Boolean and toggle closure into the
detail. A `let` input receives data, a binding permits read/write access, and
a closure can expose one focused action. Each screen owning its own favorite
set would produce conflicting selections.

The supplied reference keeps choices in memory. Tab switching should preserve
them during a launch; termination resets them. Saving source preserves code,
rather than the running app's current choices.

## Core project

1. Keep the three tabs and schedule. Open an activity detail from a Home row.
2. Own favorites in ContentView. Pass the toggle action to the detail and show
   selected records in Favorites.
3. Replace the Favorites TODO with a meaningful empty state or the filtered
   list. Keep favorite labels consistent with the next available action.
4. Add one focused information or editor sheet for the course's presentation
   exercise. Own its presentation Boolean at the presenting view, attach
   `.sheet(isPresented:)` there, and provide dismissal. Returning must
   preserve the current activity and favorites. The reference demonstrates
   tabs and drill-down navigation; this additional sheet remains an assignment.

Pause after drawing the parent/tab/detail tree. Trace the property changed by
the detail button and the views that read it. Retain an action/expected/observed
table before comparing the reference.

## Verify

| Action | Expected evidence |
| --- | --- |
| Cold launch; open all tabs | Home, Schedule and empty Favorites are reachable |
| Open Photo Walk from Home | Its own information appears; Back returns to Home |
| Save Photo Walk and switch tabs | Favorites contains it once; Schedule is unchanged |
| Return to detail and remove it | Membership and action agree; Favorites becomes empty |
| Select two activities, then remove one | The other retains its identity and membership |
| Present and dismiss the added sheet | Dismissal works without losing the existing selection |
| Test small display and larger text | Rows, detail and actions remain reachable |
| Terminate and relaunch | The in-memory reference returns to its initial empty set |

The reference adds HeroCard, ActivityRow, a summary and ActivityDetailView.
Compare shared ownership and actual selection behavior. Optional extensions
make Favorites rows open details or persist selections in the storage module.
