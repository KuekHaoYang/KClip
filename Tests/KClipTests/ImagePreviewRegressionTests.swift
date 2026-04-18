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
