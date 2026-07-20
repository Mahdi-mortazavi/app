# Nava v3.0 Deep Audit Report

Audited at `main` = v2.3.0. Verification environment: real-Flutter CI
(`flutter analyze` + `flutter test`) — no local device; device-only scenarios
are covered by implementation + `QA_CHECKLIST.md`, not by false claims of
on-device testing.

Legend: 🔴 Critical · 🟡 Major · 🔵 Polish · ✅ verified already fixed in v2.x

---

## A) Logic & State (Riverpod)

### 🔴 A1 — Out-of-order persistence can drop data (FIXED in this release)
Every mutation in `TasksNotifier` updated state, then `await`ed side effects
of *variable latency* (notification cancel/schedule, haptics) **before**
persisting a captured snapshot (`_persist(next)`). Two rapid mutations (e.g.
toggling two tasks quickly) could persist out of order: the slower first
mutation writes last with a list that lacks the second change → the second
change silently disappears on next app launch.
**Fix:** persistence is now (1) enqueued immediately after the state update,
before any side effect, and (2) serialized through a write queue that always
saves the *current* state at write time, so the final write always contains
every change. Same pattern applied to `StatsNotifier`. Regression test added
(`test/persistence_race_test.dart`).

### 🟡 A2 — System clock / timezone change during a focus session
`FocusSessionState.remainingSeconds` derives from `DateTime.now()` deltas. A
manual clock change mid-session shifts the countdown. **Decision (see
DECISIONS.md):** accepted trade-off — wall-clock is the only reliable basis
across process suspension (monotonic clocks pause in deep sleep), clock
changes mid-session are rare, and the background completion alarm re-anchors
the session. Documented, not "fixed".

### ✅ A3 — Notification IDs overflowed Android's 32-bit limit
Fixed in v2.0.1 (`NotificationService.safeId`), regression-tested.

### ✅ A4 — Timer/AnimationController lifecycle
`_PulsingGlow` disposes its controller; the focus ticker is cancelled in
`ref.onDispose` and on stop/pause/complete; `TaskForm` disposes its
`TextEditingController` and removes its listener. No leaks found.

### 🔵 A5 — `statsViewProvider` reads `DateTime.now()` per provider read
Not reactive across midnight while the app stays open on screen; corrects on
any rebuild. Accepted as polish-level; noted for a future date-change ticker.

## B) UI/UX

### ✅ B1 — Overflow guards, RTL, touch targets, Dynamic Type, Reduce Motion
Verified present from the v1.1.0 accessibility pass (44pt targets via
`TappableIcon`, `maxLines`/ellipsis on user text, `AlignmentDirectional`,
clamped `textScaler`, Reduce-Motion fallbacks).

### 🟡 B2 — Jank risk: every glass tile carries its own BackdropFilter
`BackdropFilter` is one of the most expensive Flutter operations; a long
scrolling list of tiles each with a blur can drop below 60fps on mid-range
devices. **Fix in this release:** `RepaintBoundary` isolation around each
glass surface + slightly reduced default sigma for in-list surfaces.

### 🔵 B3 — Corner geometry is plain circular, not continuous ("squircle")
Apple's material language uses continuous corners. **Fix in this release:**
`LiquidGlass` migrated to continuous-corner shape + a specular top highlight
for a more physical glass read.

### 🔵 B4 — Dark mode
The canvas is light-only. Deferred (see DECISIONS.md): a real smoked-glass
dark theme is a design project of its own; shipping a half-tuned dark theme
would violate the "no accidental pixels" bar.

## C) Notifications & Background

### ✅ C1 — POST_NOTIFICATIONS runtime flow
Manifest permission + runtime request + custom priming sheet exist. Denial
does not crash (reminder simply isn't scheduled; picker is gated).
🟡 Remaining gap: no persistent "open Settings" banner after a hard denial —
requires a settings-intent plugin (new dependency); deferred, documented.

### ✅ C2 — Exact alarms
`SCHEDULE_EXACT_ALARM` declared; `exactAllowWhileIdle` with automatic
fallback to `inexactAllowWhileIdle` when rejected. Doze-safe scheduling mode
is the correct one.

### ✅ C3 — Reboot rescheduling
`ScheduledNotificationBootReceiver` + `RECEIVE_BOOT_COMPLETED` are wired in
the manifest — flutter_local_notifications re-schedules pending
notifications after reboot. Verified present.

### ✅ C4 — Real IANA timezone
`flutter_timezone` resolves the device zone; falls back gracefully.

### 🟡 C5 — Single notification channel for everything (FIXED in this release)
Reminders and focus-session alerts shared one `focus_channel`. **Fix:** split
into `reminders` (high importance) and `focus_session` (default importance)
channels with brand color, per-purpose user control in system settings.

### 🟡 C6 — OEM battery killers (Xiaomi/Samsung/Huawei)
No in-app guidance exists for excluding Nava from aggressive battery
optimization. Requires either a plugin dependency or OEM-specific intents
(fragile). Deferred with manual-QA guidance in `QA_CHECKLIST.md`.

### 🔵 C7 — No ongoing (chronometer) notification during a focus session
The session schedules a completion alarm when backgrounded (correct + cheap),
but there is no live ongoing notification with remaining time. Needs a
foreground service (`foregroundServiceType`) — meaningful scope; deferred and
documented as the top v3.x candidate.

## D) Build & CI

### 🔴 D1 — Release builds are debug-signed (FIXED in this release)
`buildTypes.release.signingConfig = signingConfigs.debug`. **Fix:** standard
`key.properties` conditional signing — if the keystore secrets exist the
build is release-signed; otherwise it falls back to debug signing and the
release notes say so explicitly. Workflow decodes `KEYSTORE_BASE64` when
present.

### 🟡 D2 — `applicationId = "com.example.app"`
Placeholder ID; unpublishable to Play Store. **Deliberately NOT changed**:
changing it breaks the upgrade path for every existing GitHub-release install
(a different applicationId is a different app — users would lose data).
Needs a one-time owner decision; see DECISIONS.md.

### 🟡 D3 — Release artifacts: single-ABI only (FIXED in this release)
Only arm64-v8a was published. **Fix:** release pipeline now builds
arm64-v8a + armeabi-v7a + universal, generates `SHA256SUMS.txt`, and
publishes a bilingual download table.

### 🔵 D4 — `targetSdk = 34` hardcoded
Acceptable today; noted for the next toolchain bump.
