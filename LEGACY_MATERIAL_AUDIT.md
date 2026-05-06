# Legacy Swift Material Audit

This note records the review of the legacy `AD1`-`AD6` PDFs in this folder and
the old source repo at `https://github.com/instruction-material/Swift/tree/main`.

## Decision

Do not integrate these legacy materials into the active Swift course as core
curriculum.

Keep them only as historical reference material.

## Why

1. The current course is broader and structurally stronger.

The active Swift course in
`/Users/jacobanderson/Sites/classes.jacobdanderson.net/front-end/src/stores/courses/intro-to-swift-app-development.ts`
is a 20-module sequence that covers setup, signing, device testing,
publishing, Swift basics, state, navigation, CRUD, maps, networking,
persistence, debugging, accessibility, and capstone shipping.

The legacy PDFs are a much smaller six-module sequence that focuses on early
SwiftUI demos and instructor workflow.

2. Much of the legacy content is already represented in better form.

- `AD1` covers setup, Hello World, image overlay, and basic navigation.
  Those ideas are already covered more cleanly by the current `SAD2`, `SAD7`,
  and `SAD8` material plus the `SAD1-Welcome-Profile-App`.
- `AD2` covers stacks and structs.
  Those ideas are already covered by the current `SAD8`-`SAD10` material and
  the `SAD1` and `SAD3` project work.
- `AD3` covers arrays, `@State`, a button-driven gallery, and a scroll gallery.
  Those ideas are already represented more cleanly by the current `SAD11`,
  `SAD12`, and `SAD14` material, especially `SAD2-Media-Gallery-App`.
- `AD5` covers landmarks and maps.
  Those ideas are already represented by the current `SAD14` map unit and the
  `SAD4-Map-Places-App`.
- `AD6` is a master project.
  That role is already covered by the current `SAD19` and `SAD20` publishing
  and capstone flow.

3. The legacy materials contain platform-specific instruction flow that does not
fit the current system.

The PDFs include legacy Juni workflow material such as:

- learner portal navigation
- recording studio instructions
- sharing to profile or clubs
- instructor session-note guidance
- homework scripting
- internal course-sequencing notes

Those are not appropriate for the generalized student-facing course system.

4. The old source repo is not structured well for direct reuse.

The repo at `instruction-material/Swift` is a minimal one-commit snapshot with
folders like `Mod1Pro1` through `Mod5Pro3`.

It does not match the current material standards:

- no starter/solution separation
- no repository-level README explaining project order
- mostly single-file demos rather than stronger project scaffolds
- legacy API style and naming
- not organized around the current course outcomes

Directly merging it would weaken the current course rather than improve it.

## Per-Module Recommendation

### `AD1`

Discard as active curriculum.

Conceptually covered already.

### `AD2`

Discard as active curriculum.

Conceptually covered already.

### `AD3`

Discard as active curriculum.

Conceptually covered already by stronger media/state/navigation material.

### `AD4`

Do not integrate into the core course.

This is the only part worth preserving as optional enrichment.

It has now been extracted into `SADX-SwiftUI-Shapes-Studio`, a separate
starter/solution pack for optional use.

### `AD5`

Discard as active curriculum.

Map concepts are already handled more cleanly in the current system.

### `AD6`

Discard as active curriculum.

The current capstone and publishing path is more mature and more realistic.

## Practical Outcome

Keep the PDFs only as legacy reference material.

Do not port their text into the site course JSON.
Do not import the old `instruction-material/Swift` source tree into the active
starter/solution system.

If future expansion is wanted beyond that, continue treating `AD4` as optional
enrichment rather than as a core required module, and do not attempt a
wholesale merge of the legacy course.
