# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

TPTweak is an iOS debugging library (UIKit, Swift) shipped via both SwiftPM and CocoaPods.

## Build & test

```bash
swift build
swift test --enable-test-discovery --enable-code-coverage
xed TPTweak.xcworkspace   # open the library + Example app together
```

There is no root `.xcodeproj` — `.gitignore` excludes `/*.xcodeproj` by design. The workspace references the SPM package plus `Example/Example.xcodeproj`. CI runs `swift build` / `swift test` only; there is no `xcodebuild` or simulator destination anywhere in the repo.

Tests are XCTest, not Swift Testing.

## Versioning

`TPTweak.podspec` line 3 is the **only** source of truth for the version. Three other places must be updated to match, and they have drifted before:

| File | What to change |
|---|---|
| `TPTweak.podspec` | `spec.version` — canonical |
| `CHANGELOG.md` | prepend a new `# <version>` section |
| `README.md` | `.package(url: ..., from: "<version>")` |
| `README.md` | `pod 'TPTweak', '~> <version>'` |

`Example/` does **not** carry a TPTweak version — it links the library as a local SPM product through the workspace, so it always tracks the working tree. Its `MARKETING_VERSION = 1.0` is the sample app's own version; leave it alone. `Package.swift` has no version literal either (SPM resolves from git tags).

Git tags are bare version numbers with **no `v` prefix** (`4.0.0`, not `v4.0.0`) — the podspec uses `:tag => "#{spec.version}"`, so the tag must equal the podspec version exactly.

Use `/release <version>` to perform a bump.

## CHANGELOG format

Newest first. One `# <version>` H1 per release — bare version, no `v`, no date, no `[brackets]`, no link. Flat `- ` bullets, free-form sentences, no `### Added`/`### Fixed` subsections, no "Unreleased" section. Blank line between the last bullet and the next heading.

## Releasing

Publishing is manual and irreversible:

```bash
make publish   # bundle install && bundle exec pod trunk push TPTweak.podspec --allow-warnings
```

`--allow-warnings` is required: the podspec's `Core` subspec sets a non-recursive `source_files` that conflicts with the top-level recursive glob.

The `podspec.yml` workflow runs on GitHub release creation but only runs `pod spec lint` — it does not publish.

Never run `make publish`, push tags, or create GitHub releases unless explicitly asked.

## Gotchas

- **The repo moved from `tokopedia` to `wendyliga`.** `spec.source` and the git remote point at `wendyliga/ios-tptweak`; `spec.homepage`, README links, CHANGELOG PR links, and `.ownership.json` still say `tokopedia`. This is intentional — do not "fix" `spec.source` back to tokopedia.
- `Package.swift` declares `.iOS(.v10)` but the podspec declares `"11.0"`. Don't silently unify them.
- `Gemfile` pins `cocoapods 1.12.0` and `activesupport ~> 7.0.8` (the activesupport pin works around a CocoaPods 1.12 incompatibility). CI's podspec workflow uses a bare `gem install cocoapods` instead of bundler, so CI and local publish run different CocoaPods versions.
- No SwiftLint or swift-format config exists. Match surrounding style rather than reformatting.
- The library supports back to iOS 10/11, so new UIKit API use needs `if #available(...)` guards — see the `UINavigationBarAppearance` blocks in the view controllers.
