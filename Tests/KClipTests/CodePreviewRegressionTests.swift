import Foundation
import Testing

@Suite("CodePreviewRegressionTests")
struct CodePreviewRegressionTests {
  @Test
  func trayAndOverlayUseDedicatedCodeSummaryBlocks() throws {
    let card = try source("Sources/KClip/Views/TrayCardView.swift")
    let overlay = try source("Sources/KClip/Views/ClipPreviewOverlayView.swift")

    #expect(card.contains("CodePreviewSummaryView"))
    #expect(overlay.contains("CodePreviewSummaryView"))
  }

  @Test
  func editorShowsRenderedCodePreviewWithAnimation() throws {
    let editor = try source("Sources/KClip/Views/ClipEditorOverlayView.swift")

    #expect(editor.contains("renderedPreview"))
    #expect(editor.contains("CodePreviewSummaryView"))
    #expect(editor.contains(".transition("))
  }

  @Test
  func codeSummaryShowsLanguageBadgeAndMonospacedBody() throws {
    let summary = try source("Sources/KClip/Views/CodePreviewSummaryView.swift")

    #expect(summary.contains("languageBadge"))
    #expect(summary.contains("design: .monospaced"))
    #expect(summary.contains("snippet.language.title"))
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
