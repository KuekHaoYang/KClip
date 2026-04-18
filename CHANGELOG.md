# Changelog

## v0.1.6 · 2026-04-18

- Added syntax-colored code rendering so `Rendered` previews no longer show monochrome code blocks.
- Kept animated code transitions in place while making the colored code surface update through the renderer instead of plain text fallback.
- Preserved the tighter code preview sizing introduced in `v0.1.5`.

## v0.1.5 · 2026-04-18

- Fixed SwiftUI snippet detection so copied code with property wrappers, modifier chains, and other non-trivial lines is tagged as `Code` instead of falling back to `General`.
- Recomputed derived `Code` tags when loading saved clips so plain-text false positives from the previous build no longer stay stuck in the library.
- Tightened the code preview chrome by removing the duplicated language badge in the header and shrinking the expanded code overlay to snippet-sized bounds.

## v0.1.4 · 2026-04-18

- Added rendered code preview blocks in tray cards, expanded preview, and edit mode, each with detected language labels.
- Tightened automatic `Code` tagging so it only applies to fully code-shaped clips, while allowing comment lines and markdown code fences.
- Fixed the suppression flow regression where plain links could be reclassified as `Code` after hiding the `Link` tag.

## v0.1.3 · 2026-04-18

- Corrected the compact image preview geometry so the inner preview radius now follows `inner = outer - padding`.
- Preserved the explicit fade-and-scale image transitions while removing the remaining compact-shape mismatch.
- Kept the image preview chrome free of redundant in-surface labels.

## v0.1.2 · 2026-04-18

- Removed the redundant in-preview `Image` badge so the media block only shows the actual image content.
- Added explicit image preview fade-and-scale transitions so image cards keep polished motion while swapping content.
- Preserved the rounded inset geometry for expanded previews so the visible image surface matches the container padding.

## v0.1.1 · 2026-04-18

- Added first-class image clipboard support for copied screenshots, photos, and image files.
- Added automatic `Image` tagging, bounded image preview blocks, and image-aware paste/drag export.
- Fixed Finder image-file capture so KClip stores the actual image instead of Finder's icon representation.
- Added screenshot-folder ingestion for screenshot shortcuts that save to a file without copying to the clipboard.
- Tightened the compact tray image treatment with a full-width pill preview so the image no longer reads as a square slab.

## v0.1.0 · 2026-04-18

- Initial public release of KClip for macOS.
- Added fast tray-based clipboard history with search and tag filtering.
- Added pinning, preview, editing, delete, and drag export support.
- Added branded packaging, release scripting, CI, and public project docs.
