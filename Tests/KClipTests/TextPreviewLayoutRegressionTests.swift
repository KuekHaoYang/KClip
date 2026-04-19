import Foundation
import Testing

@Suite("TextPreviewLayoutRegressionTests")
struct TextPreviewLayoutRegressionTests {
  @Test
  func textPreviewStageUsesTopAnchoredOverlayInsteadOfRaisedBottomEscape() throws {
    let stage = try source("Sources/KClip/Views/TrayPreviewStageView.swift")

    #expect(stage.contains("ZStack {"))
    #expect(stage.contains(".padding(.top, 6)"))
    #expect(stage.contains("alignment: .bottom") == false)
    #expect(stage.contains("TrayPanelLayout.overlayBottomInset") == false)
    #expect(stage.contains(".frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)") == false)
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
