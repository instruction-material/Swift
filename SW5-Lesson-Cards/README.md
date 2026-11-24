# Lesson Cards

## Run the starter

Create an iOS App project in Xcode using SwiftUI and an iOS 17 or later target. Replace the generated app entry point and ContentView with all three Swift files from one role. A site IDE export puts the files under the selected role's folder. Run on an installed iPhone simulator.

The starter shows Map a trail as Planned. Begin lesson changes the stored text to 0%. The ID is 7 and the detail is Use the north route.

## Core project

1. Replace the free-form status string with an enum. Planned has no associated value. Active carries a fraction between 0 and 1. Complete carries a date. Keep the stable ID when status changes.
2. Write a pure `label(for:)` function. Use an exhaustive switch to display Planned, the active percentage, or Complete followed by the UTC date. Append the detail only when it contains text. Use the same function for every state.
3. Add actions for planned, active at 0%, 50%, and 100%, and dated completion. Use midnight UTC on 2026-01-01 for the sample date (`Date(timeIntervalSince1970: 1_767_225_600)`).

## Check the result

Begin, move halfway, then record full progress. The card title and ID stay fixed while the label progresses through 0%, 50%, and 100%. Recording completion changes the status text to Complete 2026-01-01. Plan again restores Planned. At halfway the full label is `Map a trail: 50% | Use the north route`. Try nil and an empty string as the detail. Neither should leave a trailing separator.

Explain what information is available in a completed card that an active card at 100% still lacks. Compare the two source roles after checking the behavior.
