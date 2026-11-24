# Debug a blank tracker row

Saving three spaces in the starter creates a row with no visible title. Saving a blank field is rejected. Find the point where these two inputs start behaving differently, write a regression test and fix the model.

## Reproduce the defect

Create an iOS 17 or later SwiftUI App in Xcode. Replace its generated app and view with the three Swift files directly inside one role folder. Include all three in the app target. Keep the tests and package manifest outside the app target.

Run the starter. Save `Plan app`, then save three spaces. Record the count and visible titles after each action. At a breakpoint inside `Tracker.add`, inspect the draft length before the guard and the title being appended. A string can contain characters even when those characters draw no visible marks.

## Write the regression before the fix

With Swift 6 or later, run `swift test` from the folder containing `Package.swift`. The starter includes one passing test for an ordinary title. Its success leaves the reported input untested.

Add a second test to the selected role's `Tests/TrackerTests.swift`. Create a fresh tracker, add a named task, then attempt to add three spaces. Expect the second call to return false and the saved titles to contain only the original name. Run the tests and retain the failure that reproduces the blank row. A compile error is a separate issue to resolve before interpreting this result.

| Draft | Expected return | New saved title |
| --- | --- | --- |
| `"Plan app"` | true | `Plan app` |
| `"  Plan app  "` | true | `Plan app` |
| `"   "` | false | no new row |
| `""` | false | no new row |

Correct the shared model boundary so every caller receives the same behavior. Preserve spaces between words. Extend the tests to cover the four rows, then repeat the simulator reproduction. Record what the model tests prove and which keyboard, focus or layout behavior still requires a running interface.

## Compare the reference

A full repository copy defaults to the starter. Use `TRACKER_ROLE=solution swift test` to run the reference tests there. An export containing just one role selects it automatically. The reference trims the edges before checking and saving the normalized title. Its tests also check that a rejection preserves an existing entry's identity. Compare the first failing expectation, the narrow correction and the passing rerun with the evidence from the original attempt.
