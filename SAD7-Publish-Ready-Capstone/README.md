# SAD7 Publish-Ready Capstone

Turn a three-tab planning scaffold into a scoped app another person can test.
Complete earlier navigation, state, accessibility and testing projects first.
This release-checklist exercise does not establish that an app has been
uploaded, reviewed or published.

## Run one source role

Create an iOS App in Xcode with SwiftUI and deployment target iOS 17 or later.
Choose `starter/` or `solution/`. Replace the generated App and ContentView
with that role's `PublishReadyCapstoneApp.swift` and `ContentView.swift`, and
include both in the target. Keep one `@main` App and one ContentView. Select
an installed iPhone simulator, build and run. Record Xcode, Swift language mode,
deployment target, simulator model and OS.

The bundled fictional-data exercise needs no paid membership, credentials or
upload. Actual distribution follows the later authorized account workflow.
Keep starter edits separate from the reference.

## Define one testable primary flow

Choose an audience, need and observable outcome. For example, a fictional club
member selects an activity and reviews its details. State the starting
condition, action and expected result. Complete that flow before expanding
settings or release metadata.

Home, Explore and Settings are peer tabs with separate NavigationStacks.
Home shows ReleaseTask records; Explore and Settings are placeholders.
The existence of a tab does not mean its feature is implemented. Replace
placeholder/development instructions with the chosen app's actual content.

## Turn read-only task values into state

The starter's ReleaseTask.done is `let` and its checklist is a plain constant,
so the supplied labels are read-only. The introduction and checklist share one
List so both remain readable and reachable at larger text sizes. The reference uses `var done: Bool`
and `@State private var checklist`, then binds its toggles:

```swift
ForEach($checklist) { $task in
    Toggle(task.title, isOn: $task.done)
}
```

The projected array binding gives ForEach a binding to each element.
`$task.done` reads/writes that element's Boolean. Its ID preserves record
identity while the value changes. Derive a completion total from the array
rather than storing an independent count.

The reference stores choices in memory. Its initially checked values are
sample inputs, not evidence of a completed build or accessibility review.
Its version, build and "Internal TestFlight" strings are fixtures, too. Replace
them with truthful metadata or clearly identified sample data before handing
an app to testers. Toggling a task does not execute it or persist it across
termination.

## Core project

1. Record a scope statement with one primary flow and two deferred ideas.
   Keep this development planning in project notes.
2. Implement the chosen Explore flow using models, navigation and state from
   earlier projects. Make Home coherent with the app's real data.
3. Make the checklist editable or replace it with a feature appropriate to
   the chosen audience. If retained, distinguish executed evidence from plans.
4. Give Settings accurate information and working controls rather than
   claiming the reference's fixture distribution state.
5. Verify small-display layout, larger text, useful action labels and the
   empty/error states relevant to the chosen flow. Keep the checklist in the same scrolling
   content as the introduction so every control remains reachable.

The reference demonstrates bound toggles and populated informational tabs.
Its Explore list describes features; it does not implement every learner's
chosen primary flow. Compare state/layout, then complete and test that flow.

Pause after defining one acceptance case. Another reader should be able to
run it with supplied fictional input and no implementation explanation.

## Observe a user test

Give a tester the starting condition and desired result without prescribing
every tap. Observe unclear labels or navigation. Record input, expected result,
actual result, environment and the correction. Re-run a failed case after the
fix and retain both results.

| Case | Evidence |
| --- | --- |
| Cold launch | Correct initial identity/state and reachable primary flow |
| Complete the primary flow | Supplied input produces the intended result and a usable return path |
| Switch tabs and return | Navigation and intentionally shared state remain consistent |
| Change a task toggle | Exactly that record changes; sample checks are not claimed as executed work |
| Terminate and relaunch | The in-memory reference resets; record the chosen app's real persistence behavior |
| Small display and larger text | All necessary content and controls are reachable |
| Relevant empty/error state | A meaningful recovery route works |

## Retain the release evidence

Keep final source/Xcode project, scope, actual test table, screenshots, known
limitations, version/build identity and real data/permission requirements.
Verify a simulator build separately from any device build, archive or upload.

TestFlight and App Store distribution have account roles, signing, metadata
and review stages covered by the publishing module. Perform the authorized
stage using the account holder's approved access and record its actual result.
A checklist or simulator launch does not establish publication.

Optional extensions persist the checklist with a fresh-launch test, or address
one focused improvement observed in the user test.
