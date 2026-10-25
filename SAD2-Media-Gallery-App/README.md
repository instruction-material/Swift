# SAD2 Media Gallery App

Build a gallery from supplied fictional artwork records. The starter already
filters categories and opens a detail screen. Add shared favorites and improve
the detail content. Complete the views, state and collection lessons first.

## Run one source role

Use Xcode's iOS App template with SwiftUI and deployment target iOS 17 or later.
Choose `starter/` or `solution/`. Replace the generated App and ContentView
with that role's `MediaGalleryApp.swift` and `ContentView.swift`, including
both in the target. Keep one `@main` App and one ContentView declaration.
Select an installed iPhone simulator, build and run. Record Xcode, Swift
language mode, deployment target, simulator model and OS.

The pictures are colored SwiftUI shapes and system symbols. This exercise needs
no asset download, photo library, camera, account or permission. A preview and
a running simulator are separate checks. Keep starter edits separate from the
reference.

## Follow the data and selection

Artwork groups a title, category, accent color and summary. Its Identifiable ID
lets ForEach associate each card with a record. Keep that ID stable while
filtering and selecting; create IDs with records, not in a computed filter.

`selectedCategory` is local `@State`. The picker receives
`$selectedCategory`, a binding that can read and change it. Its string tags
match the stored category values. The starter already implements this filter:

```swift
private var filteredArtworks: [Artwork] {
    if selectedCategory == "All" {
        return artworks
    }
    return artworks.filter { $0.category == selectedCategory }
}
```

The filter derives a collection without removing records from artworks.
Predict the results: All has four cards, Photo two, Workspace one and
Illustration one. The existing comment suggests future refactoring, rather
than indicating a missing filter.

LazyVGrid uses two flexible columns at standard text sizes and one at
accessibility text sizes. `dynamicTypeSize.isAccessibilitySize` selects the
column layout. Cards keep their available width and let text grow vertically.
A NavigationLink passes the selected artwork to ArtworkDetailView; its
`let artwork` is an input value, rather than another data lookup.

Both detail screens use a ScrollView so the complete description stays
reachable on a small display. Text uses
`fixedSize(horizontal: false, vertical: true)` to wrap within its width without
ending in an ellipsis. The reference's favorite label follows the same rule.

## Own favorites in the common parent

The reference owns `@State private var favorites = Set<UUID>()` in ContentView.
A set stores selected IDs without duplicates. Membership reads
`favorites.contains(artwork.id)`. Toggling removes an existing ID or inserts
an absent one. Changing category should not recreate that set.

The detail receives an `isFavorite: Bool` value and an
`onToggleFavorite: () -> Void` closure. Its button requests the parent's
mutation. Cards, detail labels and the total should all describe that same
selection. Keeping a separate count would introduce redundant state.

These are in-memory choices. Saving source in the course workspace preserves
code, not the running app's favorites across termination.

## Core project

1. Keep the working filter and navigation. Add the favorite set and a toggle
   action at their shared parent.
2. Pass membership and the action to the detail. Label the action with its next
   change and show membership on the matching card with a derived total.
3. Expand fictional detail content. Keep assignment notes in this README
   and source comments; show artwork content in the running app.
4. Test small-display and larger-text layout. A ScrollView does not repair an
   oversized child automatically.

Pause after choosing the state owner. Trace one ID from card to destination,
action and updated total. Retain edited files and an expected/observed table
before comparing the reference.

## Verify

| Action | Expected evidence |
| --- | --- |
| Select every category | Counts are 4, 2, 1 and 1; All restores every record |
| Open a card and return | Correct detail opens; selected category remains |
| Toggle a favorite twice | First adds it and second removes it |
| Favorite a Photo, change category, return | Selection stays attached to that artwork |
| Use a small screen and the largest accessibility text | Cards use one column; the complete description and favorite label are readable and reachable |
| Terminate and relaunch | The in-memory reference starts with an empty set |

The reference extracts ArtworkCard, adds a detail field and shows the derived
count. Check both column layouts in a running simulator. An optional extension
adds Favorites-only filtering.
