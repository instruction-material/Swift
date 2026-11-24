# Repair the favorite editor

Open FavoriteNote.xcodeproj in the exported role folder. Choose the FavoriteNote scheme and an installed iPhone simulator with iOS 17 or later. The form shows a favorite count, a saved note and a child editor. All data is in memory.

## Reproduce the disagreement

Tap Favorite stop. In the starter the button changes to Unfavorite stop, but the count above it stays at zero. The child and parent each own a Boolean initialized to false. Updating one copy gives the button new text while the parent keeps reading its own original value.

Type “Water break.” Before selecting Save note, the saved summary still reads “No saved note.” Save, then reset. Note which observations are already correct. A temporary draft intentionally differs from the saved note until the user commits it.

## Connect the owner and editor

Keep the favorite state in ContentView, the closest common parent of the editor and count. Change the child declaration to `@Binding var isFavorite: Bool`. Pass `isFavorite: $isFavorite` when creating FavoriteEditor, alongside its existing saved-note binding. The parent derives the count from that Boolean; there is no second count to maintain.

Keep the draft local to the editor. Save copies that draft into the bound saved note. Reset clears the local draft and both shared values. In this exercise reset is explicit, and relaunch starts a new in-memory session.

## Check the result

Run Product > Test. The original starter test records the observed mismatch. After the repair update the post-tap count expectation from zero to one. Keep the initial and final zero checks. Verify the changed button label, count, saved text and reset. Compare those observations with the solution, then describe why a binding fits the favorite but a private state value fits the uncommitted draft.
