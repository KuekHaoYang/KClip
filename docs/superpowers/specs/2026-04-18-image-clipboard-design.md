# KClip Image Clipboard Design

## Goal

Extend KClip from text-only history into mixed text and image history without breaking the fast tray flow.

## Scope

- Capture direct image clipboard data.
- Capture copied image files from Finder-style pasteboards.
- Auto-assign the `Image` tag to image clips.
- Keep image previews bounded inside card and stage blocks.
- Paste image clips back into target apps.
- Export dragged image clips as `.png`.

## UX Direction

- Tray cards keep the existing compact card shell.
- Image cards use a dedicated preview block instead of dumping metadata text into the card body.
- Compact image cards use a full-width pill preview so the image itself does not read as a square slab.
- The preview stage uses a larger bounded block than the tray card, but still stays inside the tray limits.
- Motion stays restrained: existing tray springs remain, and image blocks fade/scale in subtly.

## Data Model

`ClipboardItem` now supports two payload shapes:

- text clips: `text` plus `plainText`
- image clips: `text` summary plus `imageData`

Rules:

- link detection only applies to `plainText`
- image clips are not editable in the text editor flow
- image clips always seed suggested tags with `Image`

## Capture Rules

- Prefer image payloads over text when the pasteboard exposes both.
- Prefer copied image files over generic Finder icon/image pasteboard representations.
- Accept direct PNG/TIFF image clipboard content.
- If the pasteboard contains copied file URLs, inspect them and load the first image file.
- Normalize captured images into PNG data for storage and drag/export consistency.
- Poll the configured macOS screenshot save folder so screenshot shortcuts that do not copy to the clipboard still enter history.

## Paste And Drag Rules

- Text clips keep the existing pasteboard string path.
- Image clips write PNG data to the pasteboard before triggering the synthetic paste event.
- Dragging an image clip exposes both a PNG data representation and a PNG file representation.
- Finder drops should materialize a file; rich input targets should receive image data directly.

## Constraints

- Keep every Swift source file at or under 120 lines.
- Preserve local-only storage.
- Do not regress link preview behavior for text clips.

## Validation

- `swift test`
- `./script/build_and_run.sh --verify`
- `./script/make_release.sh v0.1.1`
- manual smoke check: copy screenshot, copy image file in Finder, paste both from KClip
