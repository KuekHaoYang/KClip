# KClip

KClip is a native macOS clipboard manager built with SwiftUI and AppKit. It captures copied content in the background, keeps it searchable, lets you organize items into pinboards, and ships as a menu-bar-first desktop utility with a floating recall window.

## What it does

- Tracks clipboard history for text, links, images, files, PDFs, and copied colors
- Opens with a floating overlay window and a menu bar controller
- Supports type-to-search plus filters for content type and source app
- Lets you create pinboards and assign items into them
- Includes quick preview, rename, note creation, and item reopening flows
- Persists local state into Application Support so history survives relaunches
- Registers global shortcuts for opening the overlay, toggling stack capture, and pausing capture

## Project layout

- `Sources/KClip/Models`: clipboard data models and persisted state
- `Sources/KClip/Services`: monitoring, hotkeys, window management, persistence, status item
- `Sources/KClip/Store`: app state and clipboard operations
- `Sources/KClip/Views`: overlay UI, preview sheet, editors, settings
- `Tests/KClipTests`: focused logic tests for filtering and core model behavior
- `scripts/build_release_app.sh`: repeatable release bundling script that emits a `KClip.app`

## Build

```bash
swift build
swift test
```

## Run

```bash
swift run
```

## Build a release app bundle

```bash
./scripts/build_release_app.sh
```

The release script creates:

- `dist/KClip.app`
- `dist/KClip-macOS.zip`

## Local data location

KClip stores its local state at:

```text
~/Library/Application Support/KClip/state.json
```

## Current boundaries

- Sync and collaboration are not implemented in this build
- Shortcuts are fixed rather than user-customizable
- The app is local-first and does not depend on a backend service
