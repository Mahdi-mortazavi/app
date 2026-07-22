# Nava v4 Design Audit — "Golden Gate" pass

Audited at v3.0.0. Scope note (honest): this repo ships **Android APKs** via the
release pipeline; desktop/web directories exist but are not built or released.
This pass therefore implements the shared token + motion system and the mobile
(iOS-grade) experience; desktop density/layout adaptation is architecture-ready
but not exercised by any shipped target. No device is available in this
environment — 60fps/blur budgets are enforced by architecture (compositor-safe
properties, glass-layer count) and verified by CI, not measured on hardware.

## Information architecture (wayfinding test)

| Screen | Where am I? | Where can I go? | What's here? | How do I exit? | Verdict |
|---|---|---|---|---|---|
| Home | «کارها» large title | Focus (per task), task sheet, goal ring | pinned, active, done lists + momentum | n/a (root) | ✅ pass |
| Task sheet | title «کار جدید/ویرایش» | save / delete / reminder picker | full task editor, progressive disclosure | drag-down / save | ✅ pass |
| Focus | task title + category | back | timer, ±5, pause/resume | X + completion actions | ✅ pass |

IA is sound: one root screen, one modal editor, one immersive mode. Nothing to
cut; two screens is already the minimal purposeful structure.

## Law-level failures found (fixed in this pass)

### 🔴 A — Glass applied to content (Laws 3–4, perf budget)
`TaskTile`, `PinnedCard`, `MomentumCard` are Liquid Glass **inside a scrolling
list**: unbounded BackdropFilter layers per screen (one per visible tile),
directly against the ≤4-glass-layers budget, and semantically wrong — glass is
for the chrome that floats above content, not the content itself.
**Fix:** content moves to a new `SolidCard`/`SolidCardTap` surface (opaque
fill, continuous corners, hairline border, token shadows — zero blur). Glass
remains only on true chrome: collapsing header, add button, sheets/popovers,
and the Focus screen's floating controls. Glass-layer count on Home drops from
O(n) to 2 (header + FAB).

### 🔴 B — No dark mode
The app renders light-only and hardcodes `statusBarIconBrightness`. iOS-grade
apps treat appearance as a first-class axis.
**Fix:** full semantic scheme (`NavaColors.light/.dark`) resolved from system
brightness — smoked-glass chrome, true dark canvas, adjusted specular/ink —
plus per-brightness status-bar style.

### 🟡 C — Hairline divider under floating chrome (Law 8)
`MinimalHeader` draws a 0.6px bottom border where content meets chrome.
**Fix:** removed; the existing progressive blur+gradient *is* the scroll-edge
effect.

### 🟡 D — No spring motion, no interruptibility
Press feedback = `AnimatedScale` with a fixed-duration curve: not velocity
aware, restarts from target on interruption.
**Fix:** `motion.dart` module — SwiftUI-parameterized springs
(`response`, `dampingRatio`) mapped to Flutter `SpringDescription`s, used by a
rebuilt press interaction that (a) responds on pointer-down immediately,
(b) starts every retarget from the current presentation value + velocity
(interruptible by construction via `SpringSimulation`), (c) reserves bounce
for release only.

### 🔵 E — Typography tracking
Type scale lacked size-specific tracking (negative for display sizes, ~0 body,
positive captions). Fixed in tokens.

## Deliberately NOT done (with reasons)
- **macOS/desktop chrome (sidebar, hover, context menus):** no desktop target
  is built or released by this repo's pipeline; shipping unexercised desktop
  layouts would be untested decoration. Tokens/motion are shared and ready.
- **User-facing transparency preference setting:** respecting the OS
  reduced-transparency/high-contrast signal is implemented; an in-app slider
  duplicating an OS setting adds a preference surface this app doesn't need.
- **Glass droplet merge/split morphing:** requires custom shader work;
  the materialize (blur+scale together) enter/exit is implemented instead.
