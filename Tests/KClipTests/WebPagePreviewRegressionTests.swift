import Foundation
import Testing

@Suite("WebPagePreviewRegressionTests")
struct WebPagePreviewRegressionTests {
  @Test
  func linkPreviewUsesWebKitSnapshotsAndWebViewPreview() throws {
    let loader = try String(contentsOf: sourceURL("Sources/KClip/Services/LinkPreviewLoading.swift"), encoding: .utf8)
    let overlay = try String(contentsOf: sourceURL("Sources/KClip/Views/ClipPreviewOverlayView.swift"), encoding: .utf8)

    #expect(loader.contains("WKWebView"))
    #expect(loader.contains("takeSnapshot"))
    #expect(overlay.contains("LinkPreviewSummaryView(preview: preview, compact: false)"))
    #expect(overlay.contains("WebPagePreviewView(") == false)
    #expect(overlay.contains("openLink") || overlay.contains("NSWorkspace.shared.open"))
  }

  private func sourceURL(_ path: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: path)
  }
}
