# SAD5 SwiftData Tracker

This is the SW11 persistence continuation of the in-memory Simple Tracker.
It uses Swift 6, SwiftUI and SwiftData with an iOS 17-or-later target. The
reference saves tracker records locally, queries them into the list and keeps
changes across a fresh app launch.

## Project

Move the tracker from an array owned by an observable store to a persistent
model. Add, edit, toggle and delete records; keep IDs stable; reject blank
titles; and show a storage error when a change cannot be saved. Save commits
an edit, while Cancel discards its local draft. A new database begins empty.
Deleting the last item must stay empty after relaunch rather than reseeding it.

The starter has a working model, query, add action and completion toggle. It
initially launches an **in-memory** container. Complete its edit/delete UI and
switch its app entry point to the file-backed container. The reference includes
these completed behaviors. Each role is a separate runnable app.

## Run

1. Create an iOS App project in Xcode using SwiftUI and Swift. Set its deployment
   target to iOS 17 or later. SwiftData does not run in the browser editor.
2. Select `starter/` or `solution/` and add all four files to the app target:
   `PersistentTrackerApp.swift`, `ContentView.swift`, `TrackerRecord.swift` and
   `TrackerPersistence.swift`. Replace the generated app entry point and
   ContentView. Use a new project, or remove the prior in-memory project's
   files from the target; keep one `@main` and one ContentView.
3. Keep `Package.swift` and both files under `tests/` out of the iOS app target.
   The package defines a separate Swift Testing target; the contract driver
   has its own command-line entry point.
4. Run on an installed iPhone simulator. Add a fictional item, mark it complete,
   edit its title and restart the app. In the reference, the same item and
   completion state return. In the starter, they reset until its app entry
   point changes `TrackerRootView(inMemory: true)` to `inMemory: false`.

## Model, container, context and query

`@Model` makes `TrackerRecord` a persistent reference type. Its fields describe
stored data: a unique UUID, title, completion flag and creation time. Unlike a
struct copy from SW10, two references can point to the same model object.
Changing that object can therefore affect the displayed record immediately.

`ModelContainer` opens the database and knows its schema. The configuration uses
a local `CourseTracker/tracker.store` file under the app's Application Support
directory. CloudKit is disabled. A preview or test explicitly chooses a fresh
in-memory container instead; it never shares the app's database.

`ModelContext` tracks inserted, changed and deleted models. The repository
validates a title, changes a model, then calls `save()`. Autosave is disabled
so this lesson has one explicit commit boundary. If save throws, `rollback()`
restores the context and the error reaches the UI. The add field or edit draft
is retained so it can be corrected or tried again.

`@Query(sort: \TrackerRecord.createdAt)` supplies the list from the current
context. It observes model changes without copying them into a second array.
Editing a title leaves the creation time and UUID unchanged. When a deletion
begins, map the displayed offsets to IDs before changing the context, then
remove those records in one save.

The editor holds a separate `@State` String initialized from the record's title.
Typing does not mutate the model. Save passes the title and original ID to the
repository; Cancel dismisses without calling it. A blank title is disabled in
the form and also rejected by the repository.

## Failure behavior

Opening a database can fail before the list exists. `TrackerRootView` shows
that error with Retry and keeps trying the same configured storage location.
It does not replace an unavailable saved database with a new in-memory store.
Its optional `storeURL` parameter supports an isolated failure demonstration
without touching the normal app database.

The query also exposes `fetchError`. The list reports a failed read separately
from a successful empty result; an unavailable query is not labeled "No items".

A write can also fail after a database opens. Before changing a model, the
repository checks that its configured stores allow saving and explicitly
rejects a read-only configuration. This keeps platform-specific save behavior
from being treated as a successful write. For other save errors, the reference
reports the failed change and rolls it back. It does
not clear an unsaved add title or dismiss an unsaved edit. Retry after resolving
the storage issue; do not delete the database as an error-recovery shortcut.

## Work sequence

1. Trace one Add action from the field through validation, model insertion,
   `save()` and the updated query. Try whitespace around a title and a blank
   title; identify which one changes stored data.
2. Complete editing with a local title draft and ID-based save. Edit a completed
   item, confirm its state remains complete, then open another edit and cancel.
3. Complete deletion by mapping query offsets to IDs. Delete one item and then
   all items; confirm the empty state.
4. Switch the starter to file-backed storage. Force quit and relaunch after
   create, edit and delete. Verify the UUID, title and completion state, not
   just the number of rows.
5. Run the supplied contracts. Explain why a fresh in-memory container isolates
   a test, while a new process opening the same file verifies persistence.
6. On a small and a large iPhone, repeat the UI flow with a long title and larger
   accessibility text. Confirm edit actions and all list items remain reachable.

## Schema decisions and migration

The current reference defines `TrackerSchemaV1` and a one-version migration
plan. Keep that version unchanged when introducing another schema. Merely
changing the version number does not describe how existing data should change.

For a rename exercise, copy V1 into a V2 schema, change its version identifier
and rename the property in the new model. An attribute annotation such as
`@Attribute(originalName: "title")` identifies the old stored name. Retain both
schemas in the migration plan, add the appropriate lightweight stage and point
the app at V2. Update its query/UI and verify a copy of a V1 database before
using the changed app. A property removed from the model can lose its stored
value; a new required field needs a compatible default or a deliberate migration.

An app's schema changes need their own migration proof. The supplied verifier
covers the current V1 store, CRUD, errors and relaunch behavior. It does not
certify an arbitrary future V2. For a simpler boundary, compare how UserDefaults
stores a small encoded value with how SwiftData manages records and queries;
these are different implementations with different schema responsibilities.

## Verification

On a Mac with Xcode installed, run from this project folder:

```sh
python3 verify-persistence.py --ios --proof /tmp/swiftdata-tracker.json
```

The pack also contains five Swift Testing cases using `@Test` and `#expect`.
They cover stable edits, rejected input, failed-save rollback, selected deletion
and preview isolation. Run them directly with:

```sh
swift test --scratch-path /tmp/swiftdata-tracker-testing
```

The package tests the reference core when both roles are present. A selected-role
export contains only its chosen role, so the same command tests that role's core.
The test target uses the role's actual model and repository files; it does not
include the app entry point or UI. It has no external package dependencies.

Use a new proof path per attempt. The verifier runs the Swift Testing suite and
28 model contracts for each
included role, including blank/missing IDs, stable edits, rollback for failed
insert/edit/toggle/delete operations, isolated memory stores and unavailable
storage. It then launches separate processes against the same temporary file
to create, read, edit, reopen, reject a real read-only write, reopen, delete and
verify the empty store. It also typechecks the complete app with the installed
iOS simulator SDK. A downloaded single-role pack can run the same verifier.

Model contracts and SDK checks do not execute the SwiftUI app. Record the
simulator UI checks separately before treating the entire app workflow as
verified. Use fictional data for the course's local stores and test database.

## API references

- [Apple: Preserving model data across launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
- [Apple: ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer)
