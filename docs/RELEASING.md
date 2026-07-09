# Releasing Nava — the autonomous pipeline

Nava ships itself. You never hand-edit a version number, write release notes,
or upload an APK by hand. Here is the whole loop.

## The developer's job: Conventional Commits

Name pull requests using [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Meaning | Version effect |
|---|---|---|
| `feat:` | a new feature | **minor** (2.0.0 → 2.1.0) |
| `fix:` | a bug fix | **patch** (2.0.0 → 2.0.1) |
| `perf:` | a performance improvement | patch |
| `a11y:` / `ui:` / `refactor:` / `docs:` | quality changes | shown in notes, no bump alone |
| `feat!:` or a `BREAKING CHANGE:` footer | breaking change | **major** (2.0.0 → 3.0.0) |

The **PR Title Lint** check enforces this, so the release notes stay clean.

## What happens automatically

1. **On every push/PR** — `CI` runs `flutter analyze` + `flutter test`. Nothing
   merges without passing.
2. **On merge to `main`** — `release-please` reads the new commits and opens (or
   updates) a **"chore: release x.y.z" PR** that bumps `pubspec.yaml` and
   `CHANGELOG.md` to the right semver with categorized notes.
3. **When you merge that release PR** — the pipeline:
   - tags the version and publishes a **GitHub Release** with the generated notes,
   - runs the quality gate again, builds the **arm64-v8a APK**, and attaches it to
     the release.

The README's version/download badges point at `releases/latest`, so they update
themselves — no README edit per release.

## One-time setup (repository owner)

release-please needs permission to open its release PR:

> **Settings → Actions → General → Workflow permissions**
> - Enable **“Allow GitHub Actions to create and approve pull requests.”**
> - Ensure **Read and write permissions** is selected.

That's the only manual switch. After that, cutting a release is just: merge PRs,
then merge the release PR.

## Cutting a release, end to end

```
# day-to-day
git checkout -b feat/my-thing
# … work …
gh pr create --title "feat: add my thing"   # title drives the version
# merge when CI is green

# when ready to ship
# → merge the auto-generated "chore: release x.y.z" PR. Done.
```
