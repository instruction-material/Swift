# SAD5 Simple Tracker App

This is the in-memory lists, forms and CRUD project for SW10. It uses Swift 6,
SwiftUI, Observation and an iOS 17-or-later target. CRUD means create, read,
update and delete. This app resets to two sample items on a fresh launch;
[SW11](../SAD5-SwiftData-Tracker-App/README.md) adds persistent storage as a separate continuation.

## Project

Build a tracker that adds a title, lists items, marks an item complete or
incomplete, edits its title and deletes selected items. Empty or whitespace-only
titles must leave the list unchanged. Save trims surrounding whitespace and
keeps the item's ID, completion state and position. Cancel leaves the item as it
was before editing.

The starter already adds items and changes their completion state. Complete
its edit form and deletion gesture using the supplied store. The reference
shows the complete workflow. Each role runs independently.

## Run

1. Create an iOS App project in Xcode using SwiftUI and Swift. Set the deployment
   target to iOS 17 or later.
2. Choose `starter/` or `solution/`. Add all four files from that role to the app
   target: `SimpleTrackerApp.swift`, `ContentView.swift`, `TrackerItem.swift` and
   `TrackerStore.swift`. Replace the generated app entry point and ContentView;
   keep exactly one `@main` type. Do not add `tests/TrackerContracts.swift` to the
   iOS app target, because it has its own command-line entry point.
3. Run on an installed iPhone simulator. The two sample items are initial data.
   A fresh app launch creates a new store; a view redraw keeps the existing
   store owned by `SimpleTrackerApp`.

## State and identity

`TrackerItem` is a value type. Its `id` identifies one item even when two titles
are the same or a title changes. Finding an item by title could update the wrong
one. The store therefore finds the current index by ID before changing it.

`TrackerStore` owns the array. `private(set)` lets views read it while keeping
mutations inside the store's methods. `@Observable` lets SwiftUI notice changes;
`@State` in the app owns one store for that running app. A preview constructs its
own store and cannot write to the app's data or another preview.

The reference editor begins with a copy of the selected item's title. Typing
changes only this local `@State` draft. Save calls `update(id:title:)`; Cancel
dismisses the editor without calling it. Binding the field directly to the
store would change the item while typing, before Save or Cancel could decide.

For deletion, SwiftUI supplies offsets from the displayed array. Remove them
from highest to lowest: deleting a low index first shifts later indices and
can remove the wrong item. The store ignores stale offsets outside its array.

## Work sequence

1. Add an item containing surrounding whitespace. Confirm its displayed title
   is trimmed, then try a blank title and confirm the list is unchanged.
2. Select an item's title to edit it. Keep the draft separate from the store,
   disable Save for a blank title and save through the item's ID.
3. Change a completed item's title. Confirm its checkmark and list position
   remain the same. Open it again, type a different draft and cancel; confirm
   the saved title remains.
4. Connect the list's deletion gesture to `store.delete(at:)`. Delete one item,
   then several items, and confirm the intended IDs are removed.
5. Force quit and relaunch. Confirm the sample list returns. Explain why this
   differs from a view redraw before adding persistence in SW11.

## Verification

From this project folder, run:

```sh
python3 verify-tracker.py --proof /tmp/tracker-contracts.json
```

The verifier compiles and runs the supplied Swift 6 store contracts. It checks
trimming, rejected inputs, duplicate-title identity, edit/save boundaries,
completion, ordered deletion and isolated in-memory stores. It runs each
included role, so a downloaded starter or reference pack can be checked alone.
Use a new proof path for each attempt to preserve previous results.

On a Mac with Xcode installed, also check the complete app roles against the
installed iOS simulator SDK:

```sh
python3 verify-tracker.py --ios --proof /tmp/tracker-ios.json
```

Store contracts and SDK typechecking do not replace using the app. On a small
and a large iPhone, exercise add, edit, Save, Cancel, toggle and delete. Repeat
with a long title and larger accessibility text; check that the full title and
form actions remain reachable. A persistence continuation must separately
verify saving, relaunching, deleting and handling storage failures.

## Completion

The completed project supports all four CRUD operations, preserves item identity
while editing and leaves saved state unchanged after Cancel or invalid input.
The store contracts pass. A short explanation connects the app-owned store,
editor draft and deletion order to the observed behavior.
