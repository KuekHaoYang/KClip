import Foundation
import CoreGraphics

extension ClipboardItem {
  init(
    imageData: Data,
    imageSize: CGSize? = nil,
    id: UUID = UUID(),
    capturedAt: Date = .now,
    sourceAppName: String? = nil,
    sourceBundleID: String? = nil,
    manualTags: [ClipTag] = [],
    suppressedTags: [ClipTag] = [],
    isPinned: Bool = false
  ) {
    self.init(
      id: id,
      text: Self.imageLabel(for: imageSize),
      imageData: imageData,
      capturedAt: capturedAt,
      sourceAppName: sourceAppName,
      sourceBundleID: sourceBundleID,
      manualTags: manualTags,
      suppressedTags: suppressedTags,
      isPinned: isPinned
    )
  }

  private static func imageLabel(for size: CGSize?) -> String {
    guard let size else { return "Image" }
    return "Image \(Int(size.width.rounded()))×\(Int(size.height.rounded()))"
  }
}
