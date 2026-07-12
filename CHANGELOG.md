# Changelog

All notable changes are recorded here. From v2.0.0 onward this file is
maintained automatically by [release-please](https://github.com/googleapis/release-please)
from Conventional Commit messages — see [`docs/RELEASING.md`](docs/RELEASING.md).

## [2.0.1](https://github.com/Mahdi-mortazavi/app/compare/v2.0.0...v2.0.1) (2026-07-12)


### 🐛 Bug Fixes

* notification IDs overflow Android's 32-bit limit (v2.0.1) ([#83](https://github.com/Mahdi-mortazavi/app/issues/83)) ([1b95c24](https://github.com/Mahdi-mortazavi/app/commit/1b95c2400ba119c02a07347a5167198f00e4ed9f))

## [2.0.1] - 2026-07-09

### 🐛 Bug Fixes
- **Notifications (Android):** task/focus notification IDs were derived from a
  millisecond-epoch value (~1.7e12) that overflows Android's 32-bit
  notification-ID limit, so reminders and focus-completion alerts could fail to
  post or become impossible to cancel. IDs are now mapped into the valid 32-bit
  range consistently across schedule/show/cancel.

### ✅ Tests
- Added regression tests for the notification-ID mapping and a widget test that
  renders the home screen with a task (covering the v2 Momentum card).

## [2.0.0] - 2026-07-09

### ✨ Features — "Momentum" (behavioral-science engagement layer)
- Daily focus goal with a progress ring (goal-gradient effect).
- Streak / "don't break the chain" with honest, date-resolved expiry
  (habit loops + loss aversion).
- Focus-completion loop that offers to mark the task done (Zeigarnik effect).
- Post-session recovery break suggestion (ultradian rhythm).
- Persistent stats layer (streak, longest streak, totals) with unit-tested
  streak logic.

## [1.1.0] - 2026-07-09

### 🎨 UI / UX
- Full **Liquid Glass** redesign; migrated state management to **Riverpod**.
- Dedicated haptics engine, background-safe focus timer, reliable reminders.

### ♿ Accessibility
- VoiceOver labels, 44pt touch targets, Dynamic Type, Reduce Motion support.

## [1.0.0] - 2025-12-03
- First public release of Nava.
