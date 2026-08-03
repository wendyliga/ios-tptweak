# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

TPTweak is an iOS debugging library (UIKit, Swift) shipped via both SwiftPM and CocoaPods.

## Build & test

```bash
swift build
swift test --enable-test-discovery --enable-code-coverage
xed TPTweak.xcworkspace    # library + both example apps + tests
xcodebuild -workspace TPTweak.xcworkspace -scheme TPTweakTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

`TPTweak.xcworkspace` is the entry point. It holds two roots: the SwiftPM package itself (`group:`) and `TPTweak.xcodeproj`. Opening it gives four schemes — `Example` (UIKit sample), `ExampleSwiftUI` (SwiftUI `WindowGroup` sample), plus `TPTweak` and `TPTweakTests` from the package.

`TPTweak.xcodeproj` contains **only** the two example app targets. The library is not duplicated as a framework target: the project carries an `XCLocalSwiftPackageReference` with `relativePath = ""` (the repo root), and both apps link the `TPTweak` product through it. So the samples consume the local SwiftPM package and always track the working tree — never a released tag or the pod.

Opening `TPTweak.xcodeproj` on its own also works for running the sample apps, but the package's `TPTweak`/`TPTweakTests` schemes are only autocreated there and `xcodebuild` cannot resolve a destination for them — the package and the project share a directory, so a scheme's `container:` is ambiguous. **Run tests through the workspace.**

`.gitignore` still excludes `/*.xcodeproj` but negates `!/TPTweak.xcodeproj`; that exclusion is for stray generated projects, so don't drop the negation.

Both app targets use `PBXFileSystemSynchronizedRootGroup` (objectVersion 77) — files are picked up from the directory automatically. **Adding a Swift file needs no `project.pbxproj` edit.** For the same reason the sample apps have no `Info.plist` on disk; they rely on `GENERATE_INFOPLIST_FILE` plus `INFOPLIST_KEY_*` settings. Dropping a `.plist` into a synchronized directory would get copied in as a resource.

Deployment target is 15.0 everywhere in the xcodeproj — Xcode 27 refuses anything below 15.0. That is unrelated to, and deliberately looser than, the iOS 10/11 floors in `Package.swift` / the podspec; when the apps build the package, SwiftPM raises it to the app's 15.0.

Tests are XCTest, not Swift Testing. Every test file is wrapped in `#if canImport(UIKit)`, so `swift test` on macOS compiles and runs **zero** tests and still reports success — to actually exercise them, run the `TPTweakTests` scheme against a simulator. CI only runs `swift build` / `swift test`, so it does not run these tests either.

The `TPTweakTests` scheme lives in `.swiftpm/xcode/xcshareddata/xcschemes/` (it belongs to the package, not the project) — keep it tracked or the scheme disappears from the workspace.

## Versioning

`TPTweak.podspec` line 3 is the **only** source of truth for the version. Three other places must be updated to match, and they have drifted before:

| File | What to change |
|---|---|
| `TPTweak.podspec` | `spec.version` — canonical |
| `CHANGELOG.md` | prepend a new `# <version>` section |
| `README.md` | `.package(url: ..., from: "<version>")` |
| `README.md` | `pod 'TPTweak', '~> <version>'` |

`Example/` does **not** carry a TPTweak version — it links the root package through a local package reference, so it always tracks the working tree. The `MARKETING_VERSION = 1.0` on both app targets in `TPTweak.xcodeproj` is deliberately **not** the library version — keeping the real version out of the xcodeproj is what stops it becoming a fifth place to drift. `Package.swift` has no version literal either (SPM resolves from git tags).

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
