import Foundation
import Testing

@Suite("ImagePreviewRegressionTests")
struct ImagePreviewRegressionTests {
  @Test
  func trayAndPreviewOverlayUseDedicatedImageSummaryBlocks() throws {
    let card = try source("Sources/KClip/Views/TrayCardView.swift")
    let overlay = try source("Sources/KClip/Views/ClipPreviewOverlayView.swift")
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(card.contains("item.isImage"))
    #expect(card.contains("ImagePreviewSummaryView"))
    #expect(overlay.contains("item.isImage"))
    #expect(overlay.contains("ImagePreviewSummaryView"))
    #expect(summary.contains("clipShape"))
    #expect(summary.contains("scaledToFit"))
  }

  @Test
  func compactImagePreviewAvoidsFooterOverflowInTrayCard() throws {
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(summary.contains("if compact"))
    #expect(summary.contains("VStack(alignment: .leading, spacing: compact ? 10 : 14)") == false)
    #expect(summary.contains("Text(item.sourceLine ?? \"Clipboard image\")"))
  }

  @Test
  func compactImagePreviewClipsImageIntoRoundedSurface() throws {
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(summary.contains("scaledToFill()"))
    #expect(summary.contains("compactThumbnail(image)"))
    #expect(summary.contains("clipShape(Capsule(style: .continuous))"))
    #expect(summary.contains("frame(width: 120, height: 46)") == false)
    #expect(summary.contains(".padding(10)"))
  }

  @Test
  func imagePreviewDropsRedundantInnerBadge() throws {
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(summary.contains("Label(\"Image\"") == false)
    #expect(summary.contains("badge") == false)
  }

  @Test
  func imagePreviewUsesExplicitMediaTransition() throws {
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(summary.contains("private var imageTransition: AnyTransition"))
    #expect(summary.contains(".transition(imageTransition)"))
  }

  @Test
  func expandedImagePreviewUsesInsetCornerRadiusFormula() throws {
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(summary.contains("expandedImageCornerRadius"))
    #expect(summary.contains("previewCornerRadius - previewInset"))
    #expect(summary.contains(".clipShape(expandedImageShape)"))
    #expect(summary.contains(".padding(previewInset)"))
  }

  private func source(_ path: String) throws -> String {
    try String(contentsOf: rootURL.appending(path: path), encoding: .utf8)
  }

  private var rootURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }
}
