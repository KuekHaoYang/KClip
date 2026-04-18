import Foundation
import Testing

@Suite("ColorPreviewRegressionTests")
struct ColorPreviewRegressionTests {
  @Test
  func trayAndOverlayUseDedicatedColorSummaryBlocks() throws {
    let card = try source("Sources/KClip/Views/TrayCardView.swift")
    let overlay = try source("Sources/KClip/Views/ClipPreviewOverlayView.swift")

    #expect(card.contains("ColorPreviewSummaryView"))
    #expect(overlay.contains("ColorPreviewSummaryView"))
  }

  @Test
  func editorShowsPaletteControlsForColorClips() throws {
    let editor = try source("Sources/KClip/Views/ClipEditorOverlayView.swift")
    let palette = try source("Sources/KClip/Views/ColorEditorPaletteView.swift")

    #expect(editor.contains("currentColorSnippet"))
    #expect(editor.contains("ColorEditorPaletteView"))
    #expect(palette.contains("ColorPicker"))
    #expect(palette.contains(".animation("))
  }

  @Test
  func colorSummaryBuildsAnimatedSwatches() throws {
    let summary = try source("Sources/KClip/Views/ColorPreviewSummaryView.swift")

    #expect(summary.contains("RoundedRectangle"))
    #expect(summary.contains("sample.swiftUIColor"))
    #expect(summary.contains(".transition("))
    #expect(summary.contains("snippet.samples"))
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
