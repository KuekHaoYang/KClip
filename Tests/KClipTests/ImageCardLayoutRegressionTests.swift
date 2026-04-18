import Foundation
import Testing

@Suite("ImageCardLayoutRegressionTests")
struct ImageCardLayoutRegressionTests {
  @Test
  func compactImageCardsDoNotRenderANestedInnerFrame() throws {
    let summary = try source("Sources/KClip/Views/ImagePreviewSummaryView.swift")

    #expect(summary.contains("compactThumbnail") == false)
    #expect(summary.contains("compactImageShape") == false)
    #expect(summary.contains("frame(height: 48)") == false)
    #expect(summary.contains("scaledToFill()"))
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
