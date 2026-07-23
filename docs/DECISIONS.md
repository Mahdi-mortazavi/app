# Engineering Decisions Log (v3.0 cycle)

Decisions taken autonomously during the v3.0 pass, with reasoning. Numbered
against `AUDIT_REPORT.md` findings.

## D-1 · Persistence race (A1): write-queue over mutex or debounce
Chose a serialized write queue that persists the *current* state at write
time. A debounce would risk losing the tail write on process death; a full
mutex around mutations would serialize UI-visible state updates too.
The queue keeps state updates synchronous (instant UI) while storage writes
are ordered and always final-state-correct.

## D-2 · Focus timer stays wall-clock based (A2)
Monotonic clocks (Stopwatch) pause during deep sleep on Android, which would
freeze the countdown across suspension — a worse and more common failure than
a user changing the system clock mid-session. Wall-clock + alarm-based
background completion is the correct engineering trade-off. Documented, not
patched around.

## D-3 · Dark mode deferred (B4)
A credible smoked-glass dark theme requires retuning every tint/border/shadow
value and re-shooting screenshots. Shipping a half-tuned dark mode fails the
"nothing accidental" bar. Scoped out of v3.0; strong v3.x candidate.

## D-4 · applicationId left as com.example.app (D2)
Changing it orphans every existing install (different package = different
app, no upgrade path, local data left behind). This is a product decision the
owner must make once, ideally before any store publication. The build is
otherwise store-ready after signing secrets are added.

## D-5 · No new dependencies added
The settings-redirect banner (C1) and battery-optimization exemption (C6)
each require a plugin. Neither is core to v3.0's promise; both are candidates
for a deliberate v3.x notification UX release. Zero new deps keeps the
supply-chain surface unchanged.

## D-6 · Ongoing focus-session notification deferred (C7)
A live chronometer notification needs a foreground service +
`foregroundServiceType` + service lifecycle management. The current
design (alarm scheduled on backgrounding, cancelled on resume) delivers the
user-visible guarantee (you're told when the session ends) at a fraction of
the complexity. Deferred to v3.x with its own design pass.

## D-7 · Versioning: release-please owns the number
release-please is live and has been cutting releases on its own. The v3.0
major bump is expressed through the PR title (`feat!:`) so the pipeline
computes 3.0.0 itself — hand-editing pubspec/manifest versions would fight
the tool that owns them.

## D-8 · Release signing is conditional, never blocking (D1)
The Gradle config reads `android/key.properties` if present; the workflow
materializes it from secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
`KEY_ALIAS`, `KEY_PASSWORD`) when they exist. Without secrets the build
falls back to debug signing and the release notes disclose it — an unsigned
hotfix must never be blocked by missing secrets.

## D-9 · v4: content cards are solid, glass is chrome-only
The v3 glass-everywhere look violated the material's own laws (glass inside
scrolling lists, unbounded blur layers). v4 splits the surface system:
`SolidCard` for content (zero blur, safe at any list length), `LiquidGlass`
for the ≤2 chrome layers per screen (header, primary action, sheets, focus
controls). This is the semantically correct Apple model AND the perf fix.

## D-10 · v4: springs via SpringSimulation, not a physics rewrite
Press feedback uses `AnimationController.unbounded` + `SpringSimulation`
parameterized SwiftUI-style (response/dampingRatio) — interruptible by
construction (every retarget starts from the current presentation value).
Full gesture-velocity handoff (sheet drag, momentum projection, rubber-band)
belongs to the packages already handling those surfaces
(`modal_bottom_sheet` drag-to-dismiss); reimplementing them wholesale was
judged churn without user-visible gain.

## D-11 · v4: dark mode ships; Focus stays always-dark
The appearance scheme (`NavaColors.light/.dark`) resolves from system
brightness. The Focus screen deliberately remains an always-dark immersive
mode (like a full-screen player) — that is a design choice, not a gap.

## D-12 · v4: reduced transparency maps to `MediaQuery.highContrast`
Flutter exposes iOS "reduce transparency"/increase-contrast via the
high-contrast flag; glass falls back to an opaque bordered surface there.

## D-13 · Screenshots render through the widget tree, not an emulator
README screenshots are produced by a tagged golden suite
(`test/screenshots/`, run by the Screenshots workflow) that pumps the real
app with seeded data and captures full-screen frames at iPhone-class
resolution — pixel-true to the shipped code and reproducible on every UI
change. Regular CI excludes the tag, so goldens can never break a release.
Side effects folded in deliberately: Vazirmatn/IBM Plex Mono now ship in
the bundle (OFL, ~0.75 MB) with `allowRuntimeFetching = false`, making
first-launch rendering fully offline; and the old `assets/shot_*.jpg`
mockups were removed from the APK bundle where they never belonged.

## D-14 · Vazirmatn is a native pubspec font, not a google_fonts runtime load
The first screenshot render exposed three real bugs the widget tests never
caught: (a) FocusPage mutated its provider in `initState`/`dispose`, which
Riverpod forbids (debug-mode crash); (b) the screens draw on a custom glass
canvas with no `Material` ancestor, so raw-styled `Text` inherited no
`DefaultTextStyle` and fell back to the platform font with the yellow
"missing Material" underlines; (c) the focus timer used IBM Plex Mono, which
has zero Persian-digit glyphs, so the countdown never actually rendered.
The durable fix for the font issues is to declare Vazirmatn as a first-class
Flutter font family in `pubspec.yaml` (all six weights) and reference it by
name everywhere — theme, typography scale, and timer — instead of loading it
through `google_fonts` at runtime. Every weight now resolves natively for any
`Text`, including raw `TextStyle`s that only inherit the family and text
inside modal sheets (the Save button that previously rendered as tofu). A
transparent `Material` in the app builder supplies text defaults app-wide.
This is the reason screenshots are worth rendering from real code: they are a
UI regression test, not just marketing images.
