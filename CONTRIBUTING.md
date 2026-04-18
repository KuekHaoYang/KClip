# Contributing

## Setup

```bash
swift test
./script/build_and_run.sh run
```

## Ground Rules

- Keep Swift files at or under 120 lines.
- Prefer focused files over oversized view or service types.
- Add or update tests for behavior changes.
- Keep the app macOS-only and local-storage-only unless the product direction changes.

## Style

- Use native macOS patterns first.
- Favor small, explicit APIs over hidden shared state.
- Keep UI changes aligned with KClip’s fast tray-first interaction model.

## Pull Requests

- Describe user-facing behavior changes clearly.
- Include validation commands in the PR body.
- If you change packaging or release scripts, verify both local build and packaged app launch.
