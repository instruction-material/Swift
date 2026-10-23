# Intro to Swift App Development

Source repository: [instruction-material/Swift](https://github.com/instruction-material/Swift).

## Project packs

1. [Welcome Profile App](SAD1-Welcome-Profile-App/README.md)
2. [Media Gallery App](SAD2-Media-Gallery-App/README.md)
3. [Multi-Tab Hobby App](SAD3-Multi-Tab-Hobby-App/README.md)
4. [Map Places App](SAD4-Map-Places-App/README.md)
5. [Simple Tracker App](SAD5-Simple-Tracker-App/README.md) and its
   [SwiftData continuation](SAD5-SwiftData-Tracker-App/README.md)
6. [API Reference App](SAD6-API-Reference-App/README.md)
7. [Publish-Ready Capstone](SAD7-Publish-Ready-Capstone/README.md)

Each pack has a project reading, a `starter/` scaffold and a `solution/` source
reference. The project reading defines the work and the expected behavior.

## Lesson order

The visible course uses SW1 through SW20:

- SW1–SW2: Mac setup, first launch and Xcode project anatomy.
- SW3–SW7: SwiftUI layout, Swift basics, functions and data types, app structure,
  and state/data flow.
- SW8–SW15: media/maps, navigation, lists/forms, persistence, networking,
  debugging/testing, accessibility and simulator/device validation.
- SW16–SW20: development/distribution, signing, App Store Connect/TestFlight,
  capstone user testing and the final publishing walkthrough.

Names such as `SAD15` in older source folders are retained aliases. Follow the SW
lesson titles for the course order.

## Run a project in Xcode

These packs contain SwiftUI source files for an iOS app target.

1. Create an iOS App project in Xcode using SwiftUI.
2. Select one role, `starter/` or `solution/`, from the assigned project. Replace
   the generated app entry point and `ContentView` with that role's source.
   Keep one `@main` app entry point in the target.
3. Add the role's remaining Swift files to the same target. Follow the project
   reading for its data, assets and feature requirements.
4. Select an installed simulator or configured device, then build and run the
   app. Verify the behavior listed in the project reading.

## Supplemental and archived material

- [SwiftUI Shapes Studio](SAD-Swift-UI-Shapes-Studio/README.md) is optional visual
  enrichment alongside the main project sequence.
- The numbered `SAD-01-…` through `SAD-41-…` folders currently provide a generic
  SwiftUI screen scaffold and a local state-toggle example. Their example does
  not implement the topic-specific requirements of the linked course activity.
- `Mod1Pro1` through `Mod5Pro3` retain individual legacy SwiftUI demonstrations.
  They are separate reference examples, without starter/solution roles.
- [Legacy archive scope](legacy/README.md) and the
  [material decision record](LEGACY_MATERIAL_AUDIT.md) distinguish historical
  references from the current project packs.

The [source manifest](COURSE_SOURCE_MANIFEST.md) records catalog links. Its
inventory check does not certify lesson completeness or an iOS build.
