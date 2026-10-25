# SAD1 Welcome Profile App

Build a two-screen profile app using fictional data. The starter contains a
welcome screen and a detail screen. Organize their information, add useful
profile content and extract a reusable view. Complete the setup and
project-anatomy lessons first.

## Open one complete source role

Use a supported Mac with Xcode and an installed iOS simulator. This pack uses
SwiftUI, `NavigationStack` and `#Preview`; use an iOS deployment target of 17 or
later. The reference also imports UIKit, so choose an iOS App target.

1. Create an iOS App project using Swift and SwiftUI. This project needs no
   persistence template, external package, signing service or paid account for
   its simulator exercise.
2. Choose either `starter/` or `solution/`. Replace the generated view and App
   declarations with that role's `ContentView.swift` and
   `WelcomeProfileApp.swift`. Include both files in the app target. Keep exactly
   one `@main` App declaration and one `ContentView` declaration; adding both
   roles to the same target creates duplicate types.
3. Select an installed iPhone simulator and run the app. Check the launched
   app as well as the preview. A working preview is a separate result from a
   simulator launch.
4. Keep the selected role and edited files together. To compare the reference,
   use a separate project or a preserved copy of the first project.

Record the Xcode version, Swift language mode, deployment target and simulator
model/OS. An ordinary Swift syntax check does not check Apple SDK availability,
preview plugins or the running interface.

## Read the app from its entry point

`WelcomeProfileApp.swift` contains the `@main` type. Its `body` describes a
`Scene`; `WindowGroup` supplies the scene's root `ContentView`. In contrast,
`ContentView.body` describes a `View`.

The starter's main hierarchy is:

```text
WelcomeProfileApp
  WindowGroup
    ContentView
      NavigationStack
        ScrollView
          VStack
            heading, profile card, starter panel, navigation link
```

SwiftUI uses this description to lay out the interface. A `VStack` arranges its
children vertically, an `HStack` arranges them horizontally and a `ZStack`
layers them. Alignment places children within the available space; spacing
separates neighboring children. A `ScrollView` lets its content extend beyond
the visible viewport. It does not automatically repair an oversized child.

`body` is not a one-time drawing command. SwiftUI can evaluate it again as
relevant data changes. Keep it a description of the current interface; do not
start downloads or write files as a side effect of evaluating it.

## Follow the data into both screens

The starter's `Profile` struct holds a name, role, hometown and array of
interests. Each property is a `let` constant. `ContentView` owns a sample
profile and reads its fields in the welcome card.

`NavigationStack` provides navigation context. The `NavigationLink` supplies
`ProfileDetailView(profile: profile)` as its destination. That argument passes
the profile value to the destination's `let profile: Profile` property. The
detail view can display that value without looking up a global profile or
making a network request. The normal navigation back action returns to the
welcome screen.

The detail screen uses a `List` containing named `Section` groups. Its
`ForEach(profile.interests, id: \.self)` produces one row for each interest.
The current exercise uses unique interest strings, because `\.self` uses the
string value as identity. Repeated labels would repeat those identities.
Later list projects introduce separate stable IDs when values may repeat or
change.

Trace one concrete change: replace the fictional hometown in the profile
initializer, then locate every expression that reads `profile.hometown`.
Predict both screens' text before running. Changing that stored sample value
changes the input supplied to both views; it is not two independent copies of
the displayed hometown text.

## Work through modifier order

A modifier returns a new view containing the previous view's behavior or
appearance. Read a chain from top to bottom. In this example, place the entire
`VStack` expression inside a SwiftUI view's `body`:

```swift
VStack(spacing: 24) {
    Text("Moon Club")
        .padding(12)
        .background(Color.orange.opacity(0.25))

    Text("Moon Club")
        .background(Color.orange.opacity(0.25))
        .padding(12)
}
```

In the first child, the background receives the already padded view, so its
colored area includes the padding. In the second, the background is attached
before the padding is added, so that outer padding is outside the colored
area. The text and padding value are identical; the composition order differs.
Compare the colored bounds in the preview, then change the padding value and
predict which bounds will change.

In the starter card, a `VStack` contains the profile text.
`fixedSize(horizontal: false, vertical: true)` lets the text wrap and keeps its
required height. Padding separates it from the card edges, and
`frame(maxWidth: .infinity, minHeight: 180, alignment: .bottomLeading)` gives
the padded stack a minimum height while allowing it to grow. The blue
`background` uses a `RoundedRectangle` to follow those bounds. These modifiers
act on different levels of the tree; moving a modifier to a parent can affect
a whole group instead of one label.

## Core project

Keep the welcome-to-detail navigation and use fictional information.

- Add `bio: String` and `goals: [String]` to `Profile`. Supply values in its
  initializer and present them in meaningful profile or goals sections.
- Replace the visible starter-task panel with profile content. Keep the task
  instructions in this README.
- Extract a reusable interest-tag view with an input array. Use it on the
  welcome screen and keep the detail screen's interests consistent with the
  same profile data. A small named view is sufficient; a generic container is
  optional.
- Give the destination an intentional About, Interests and Goals structure.
  Remove the visible `TODO` text after replacing it with actual content.
- Keep readable text, a clear navigation action and a usable back path. Check
  the chosen sample in two simulator sizes and with a larger text setting.
  Record any clipping or crowded layout instead of treating a successful build
  as proof that the interface fits.

Before comparing the reference, retain the changed files and a short result
table: action/input, expected result, observed result and selected simulator.
Check cold launch, a changed profile field on both screens, opening the detail,
returning, and the chosen text-size/layout cases.

## Read the reference after an attempt

The reference adds the profile bio and goals, a gradient header, `TagRow`, and
reusable `InfoSection` containers. `InfoSection<Content: View>` stores a
particular content-view type supplied by its caller. Its `@ViewBuilder`
property lets that content be written as a block of view expressions. This is
one factoring technique, not a requirement to learn all of Swift generics
before completing this project.

The reference also demonstrates local editable state:

- `@State private var note` owns the current note value for this view's
  identity.
- `TextField(..., text: $note, ...)` receives a binding, which can read and
  write that value.
- `Text(note)` reads the same value, so typing into the field updates the
  displayed note.

The dollar-prefixed `$note` is a binding to state, not another stored string.
This reference has no disk persistence for the note. A fresh app process
starts with its initial value. Compare that behavior with navigating to the
detail and back while the welcome view remains in the navigation stack.

Keyboard focus is separate from the note's value. The reference binds
`@FocusState private var isEditingNote` to the text field with `.focused(...)`.
Its keyboard toolbar's **Done** button sets that focus to `false`, dismissing
the keyboard without changing the note. The scroll view also supports
interactive keyboard dismissal. On a small simulator, edit the note, tap Done,
then scroll to Open Detailed Profile and navigate back. The note stays edited;
a fresh app process resets it to the initial value.

The reference header places its gradient behind the padded text stack and
uses `minHeight: 220`, so longer text can increase the banner height.
`TagRow` reads `dynamicTypeSize` from the environment. Its `AnyLayout` uses
an `HStackLayout` at standard sizes and a `VStackLayout` at accessibility
sizes, keeping the same interest views in either arrangement. Test longer
content and larger text before reusing it in another app; those layouts need
separate acceptance evidence.

## Distinct follow-up work

Choose one extension and continue the same project:

- **Adaptive interests:** Extend the two tag layouts with a width-adaptive
  grid. `LazyVGrid` accepts a `columns` array; a
  `GridItem(.adaptive(minimum: 90))` allows columns to be chosen from available
  width. Use one `ForEach` entry per interest. Compare short and long labels at
  two widths and a larger text size; tune the minimum to the actual content.
- **Editable display name:** Add local state for a display name and a bound
  text field. Keep the original `Profile` unchanged. Derive a displayed name
  by trimming leading and trailing whitespace; a blank result falls back to
  the original profile name. Add `import Foundation` for the normalization
  helper. Foundation's
  `trimmingCharacters(in: .whitespacesAndNewlines)` returns that trimmed
  string, and `isEmpty` tests whether it has content. Pass the derived display
  name as an additional input to the detail view so both screens agree.
  Preserve and wrap a long displayed name. Check ordinary, blank and long
  input, navigation and a fresh launch. Local state is not a database save.

For a challenge, add an editable goals screen with its own draft. Commit the
draft through an explicit Save action and discard it through Cancel. Keep the
original goals unchanged until Save, and show the saved result on both
screens. On Save, reject blank or duplicate goals after trimming whitespace;
compare trimmed strings case-sensitively. Show a local error and preserve the
committed goals on rejection. Record the draft owner, committed owner, navigation path and
Save/Cancel outcomes before implementing the change. The supplied reference
does not implement these extensions or the draft-editing challenge.

Primary references: [declaring a custom view](https://developer.apple.com/documentation/swiftui/declaring-a-custom-view),
[configuring views](https://developer.apple.com/documentation/swiftui/configuring-views),
[State](https://developer.apple.com/documentation/swiftui/state),
[Binding](https://developer.apple.com/documentation/swiftui/binding), and
[NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack).
