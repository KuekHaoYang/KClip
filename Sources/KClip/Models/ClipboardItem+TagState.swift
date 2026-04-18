import Foundation

extension ClipboardItem {
  var tags: [ClipTag] {
    let blocked = Set(suppressedTags)
    let merged = Self.normalized(suggestedTags + manualTags).filter { blocked.contains($0) == false }
    let contentTags = merged.filter { $0 != .general }
    return contentTags.isEmpty ? [.general] : [.general] + contentTags
  }

  var primaryTag: ClipTag {
    tags.first(where: { $0 != .general }) ?? .general
  }

  var sourceLine: String? {
    sourceAppName ?? sourceBundleID?.split(separator: ".").last.map(String.init)
  }

  func updating(text: String) -> ClipboardItem {
    ClipboardItem(
      id: id,
      text: text,
      capturedAt: capturedAt,
      sourceAppName: sourceAppName,
      sourceBundleID: sourceBundleID,
      suggestedTags: ClipTag.inferredTags(for: text),
      manualTags: manualTags,
      suppressedTags: suppressedTags,
      isPinned: isPinned
    )
  }

  func togglingPin() -> ClipboardItem {
    ClipboardItem(
      id: id,
      text: text,
      capturedAt: capturedAt,
      sourceAppName: sourceAppName,
      sourceBundleID: sourceBundleID,
      suggestedTags: suggestedTags,
      manualTags: manualTags,
      suppressedTags: suppressedTags,
      isPinned: isPinned == false
    )
  }

  func togglingTag(_ tag: ClipTag) -> ClipboardItem {
    let nextManual = tags.contains(tag) ? manualTags.filter { $0 != tag } : manualTags + [tag]
    let nextSuppressed = tags.contains(tag) && suggestedTags.contains(tag) ? suppressedTags + [tag] : suppressedTags.filter { $0 != tag }
    return ClipboardItem(
      id: id,
      text: text,
      capturedAt: capturedAt,
      sourceAppName: sourceAppName,
      sourceBundleID: sourceBundleID,
      suggestedTags: suggestedTags,
      manualTags: nextManual,
      suppressedTags: nextSuppressed,
      isPinned: isPinned
    )
  }

  func resettingTags() -> ClipboardItem {
    ClipboardItem(
      id: id,
      text: text,
      capturedAt: capturedAt,
      sourceAppName: sourceAppName,
      sourceBundleID: sourceBundleID,
      isPinned: isPinned
    )
  }
}
