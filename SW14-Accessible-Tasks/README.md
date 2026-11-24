# Make the task screen usable

Open the exported role’s TaskReview.xcodeproj in Xcode. Select the TaskReview scheme and an installed iPhone simulator with iOS 17 or later. The sample contains a single fictional field-journal task. Record a baseline at the standard text size before trying a larger accessibility text size.

## Observe the rough screen

Read the full task title in ContentView.swift and compare it with the visible title. The starter fixes both the font and the text frame. Changing status switches a colored dot without a visible status word. The icon-only save button hides its image from accessibility and supplies no replacement label. The session note appears before the controls. Delete removes the row immediately; Restore sample repopulates the exercise.

Use Accessibility Inspector to inspect names, roles and order. For an actual spoken interaction, repeat the task with VoiceOver on a supported device or simulator configuration and record what it announces. Keep an inspector observation and a listening result distinct.

## Repair the interaction

Use a scalable text style for the title and let it wrap. Replace the dot with an explicit status and use a native toggle to edit completion. Give Save task a descriptive text label and a symbol. Group the status, save and delete actions before the session note. Add a deletion confirmation with Cancel and a clearly named destructive action; keep the sample recovery available.

## Check the result

At a large accessibility text size, read the complete title and scroll to every action. Save the task and locate its Saved confirmation. Toggle status and verify both states with the screen in grayscale. Open deletion, cancel, confirm that the task remains, then repeat and confirm deletion. Restore the sample and verify it starts open. Repeat with the accessibility tree and record any barrier that remains.

The reference’s UI test launches at a large text setting and checks named controls, saving, canceling deletion and restoring the sample. It does not listen to VoiceOver or judge visual contrast. Keep a screenshot, reading-order notes and a brief account of the path actually tested alongside that automated result.
