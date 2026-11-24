# FirstLaunch

FirstLaunch is a small iOS app used for two projects. Keep the same working copy. The first task checks that the app on the simulator contains a deliberate edit. The second follows that edit through the project and changes a bundled color.

## Open and run

Save and export the selected role from the site IDE. Extract the ZIP and open `FirstLaunch.xcodeproj` **inside that role folder** in Xcode on a Mac. Select the FirstLaunch scheme and an installed iPhone simulator with iOS 17 or later. The project already includes its app and UI test targets.

Choose Product > Run. In the original starter a paper plane appears above **Ready to launch**. The reference shows **First verified launch**, a blue-green plane and **Flight journal**. A view preview helps check spacing; launching the app also checks the scheme, target, and run destination.

## SW1: Prove a first launch

In Xcode, create a separate practice project using the iOS App template, SwiftUI and Swift. Find its app entry point and generated root view. Run it on the same destination. Record which scheme belongs to each project, then return to the supplied FirstLaunch project. A simulator run requires no paid membership or physical device.

Change the title argument in `ContentView.swift` to `First verified launch`. Stop the app and run again. Record the Xcode version, Swift language mode from the target settings, deployment target, simulator model and OS, and the heading that appeared. If an earlier attempt resumes with the target heading already present, temporarily use a distinctive heading, verify it in the launched app, then restore the assigned text.

Choose Product > Test. The starter test expects the original label, so it should report the new label as a mismatch after the edit. Update the expectation in `Tests/FirstLaunchUITests.swift` and repeat. Record the observed failure and passing rerun. If the original label still appears, compare the project, scheme and destination before editing more files.

## SW2: Trace and change a bundled resource

Follow this path in the Project navigator: `FirstLaunchApp.swift` creates a window whose root is `ContentView`. That view passes its title to `ProfileHeader`. The header uses a system paper-plane symbol and reads its tint from the **ProfileAccent** color set in `Assets.xcassets`. The app target compiles the three app Swift files and bundles the asset catalog. The UI test target builds the launch test separately.

In the asset catalog change the universal ProfileAccent color from gray to a distinguishable blue-green. Add a secondary line reading **Flight journal** below the heading in `ProfileHeader.swift`. Run again and check both the symbol tint and text. Add an assertion that the second line exists to the UI test, then run the tests. The text assertion checks the label; record the tint separately from the running screen.

Inspect the app target's Build Phases and the scheme's Test action. Identify where the header is compiled, where the catalog is copied and which test bundle runs. For a missing type, first inspect its source file's target membership. For a missing color, compare the quoted asset name with the color set's name and check that the catalog belongs to the app. Record which observation would distinguish those two faults.

## Compare the reference

Keep the edited starter and open the solution separately. Trace the same visible heading from its test expectation back through the view and app entry point. Compare the asset settings and secondary label independently. Two projects can show the same words with different build settings; retain the scheme, destination and text observations alongside each result.
