# Intro to Swift App Development

This folder is structured as the future `instruction-material/Intro-to-Swift-App-Development`
repository for the site course.

The materials are organized around the recommended project sequence from the
course plan:

1. `SAD1-Welcome-Profile-App`
2. `SAD2-Media-Gallery-App`
3. `SAD3-Multi-Tab-Hobby-App`
4. `SAD4-Map-Places-App`
5. `SAD5-Simple-Tracker-App`
6. `SAD6-API-Reference-App`
7. `SAD7-Publish-Ready-Capstone`

Optional enrichment:

- `SADX-SwiftUI-Shapes-Studio`

Each project contains:

- `starter/` with a guided scaffold and TODOs
- `solution/` with one complete reference implementation
- `README.md` describing the goal of the project and how it fits the course

These source trees are intentionally Xcode-friendly rather than repository-wide
Xcode projects. The expected workflow is:

1. Create a new iOS App project in Xcode with SwiftUI.
2. Replace the generated `App` and `ContentView` source files with the files in
   the selected `starter/` or `solution/` folder.
3. Add any extra source files from the same folder into the Xcode target.
4. Reuse the folder name as the project working directory if the course needs a
   dedicated archive of screenshots, metadata, or notes.

The course itself starts with Apple ecosystem setup, simulator/device workflow,
signing, and publishing concepts before deeper Swift and SwiftUI work.

## Legacy and Optional Material

- The old `AD1`-`AD6` PDFs and `SWIFT-COMB.pdf` now live under `legacy/`.
- `AD4` was extracted into `SADX-SwiftUI-Shapes-Studio` as an optional
  enrichment pack rather than part of the core course sequence.
- The main active course path is still `SAD1` through `SAD7`.

## Legacy PDF Audit

The legacy `AD1`-`AD6` PDFs and `SWIFT-COMB.pdf` in this folder were audited
against the current course design and the old source repo at
`instruction-material/Swift`.

They are not part of the active course system.

- Do not merge them into the main `SAD1`-`SAD7` project sequence as core
  curriculum.
- Treat them as legacy instructor-reference material only.
- If anything is revived later, the only reasonable candidate is the
  shape-drawing content from `AD4`, and that has now been extracted into
  `SADX-SwiftUI-Shapes-Studio` as optional enrichment rather than a required
  project.

See `LEGACY_MATERIAL_AUDIT.md` for the full decision record.
