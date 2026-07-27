---
name: release
description: Bump the TPTweak version across the podspec, CHANGELOG, and README install snippets, keeping all of them in sync. Edits files only — does not commit, tag, push, or publish.
disable-model-invocation: true
---

Prepare a version bump to **$ARGUMENTS**.

If no version was given, stop and ask for one. Validate it looks like `X.Y.Z` (bare — reject a leading `v`).

## 1. Check the starting state

```bash
grep -n 'spec.version' TPTweak.podspec
head -1 CHANGELOG.md
grep -n -e 'from: "' -e "pod 'TPTweak'" README.md
git tag | tail -5
git status --porcelain
```

Report the current version of each of the four places. They have drifted before, so do not assume they agree. If the working tree is dirty, say so and ask whether to continue.

Confirm the new version is greater than the podspec version. If it is lower or equal, stop and ask.

## 2. Gather what changed

Find the commit that set the current podspec version, and list everything since:

```bash
git log --oneline -S'spec.version          = "<current>"' -- TPTweak.podspec
git log --oneline <that-commit>..HEAD
git diff --stat <that-commit> HEAD
git diff <that-commit> HEAD -- Sources/
```

Read the actual `Sources/` diff — commit subjects in this repo are often terse (`revert`, `update ci`) and don't describe the user-facing change. Write bullets that describe behavior, not commits. Skip pure-CI and asset-only churn unless it's the headline of the release (it was for 4.0.0).

## 3. Edit the four places

1. `TPTweak.podspec` line 3 — `spec.version`. **Preserve the column alignment**: all keys align to column 25, so it is `spec.version` followed by 10 spaces, then `= "X.Y.Z"`.
2. `CHANGELOG.md` — prepend a new section at the very top of the file (line 1), followed by a blank line before the previous top section.
3. `README.md` — `.package(url: ..., from: "X.Y.Z")`.
4. `README.md` — `pod 'TPTweak', '~> X.Y.Z'`.

Only change version numbers in README. Leave the `tokopedia` URLs alone — see CLAUDE.md.

CHANGELOG section format (match the existing file exactly):

```
# X.Y.Z
- lowercase, terse, free-form bullet
- another bullet

# <previous version>
```

No `v` prefix, no date, no `### Added`/`### Fixed` subsections, no PR links (2.x and later dropped them).

## 4. Verify

```bash
swift build && swift test --enable-test-discovery
grep -rn '<new-version>' TPTweak.podspec README.md CHANGELOG.md
git diff
```

The grep must show exactly four hits: one in the podspec, one in CHANGELOG, two in README. If it shows fewer, one of the places was missed — fix it before reporting.

## 5. Hand off — do not commit

Stop here. Do **not** run `git commit`, `git tag`, `git push`, `make publish`, or `gh release create`.

Show the diff and print these for the user to run themselves:

```bash
git add TPTweak.podspec CHANGELOG.md README.md
git commit -m "update <new-version>"
git tag <new-version>          # bare, no v prefix
git push origin main --tags
make publish                   # pod trunk push — irreversible
```

Remind them `make publish` pushes to the public CocoaPods trunk and cannot be undone.
