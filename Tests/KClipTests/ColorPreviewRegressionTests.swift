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
    #expect(palette.contains("ColorPaletteSurfaceView"))
    #expect(palette.contains("ColorPreviewSummaryView") == false)
    #expect(palette.contains("frame(height: 128)"))
    #expect(palette.contains("updatingSample("))
    #expect(palette.contains(".animation("))
  }

  @Test
  func colorSummaryBuildsAnimatedSwatches() throws {
    let summary = try source("Sources/KClip/Views/ColorPreviewSummaryView.swift")
    let surface = try source("Sources/KClip/Views/ColorPaletteSurfaceView.swift")
    let overlay = try source("Sources/KClip/Views/ClipPreviewOverlayView.swift")

    #expect(summary.contains("ColorPaletteSurfaceView"))
    #expect(summary.contains(".transition("))
    #expect(summary.contains("maxHeight: .infinity"))
    #expect(summary.contains(".background(") == false)
    #expect(summary.contains("headerRow") == false)
    #expect(surface.contains("RoundedRectangle"))
    #expect(surface.contains("sample.swiftUIColor"))
    #expect(overlay.contains("height: 236"))
  }

  @Test
  func colorSurfaceUsesInsetRadiusMathWithoutExtraContainerFill() throws {
    let surface = try source("Sources/KClip/Views/ColorPaletteSurfaceView.swift")

    #expect(surface.contains("outerCornerRadius"))
    #expect(surface.contains("previewInset"))
    #expect(surface.contains("innerCornerRadius"))
    #expect(surface.contains("outerCornerRadius - previewInset"))
    #expect(surface.contains(".padding(previewInset)"))
    #expect(surface.contains(".fill(.regularMaterial)") == false)
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
