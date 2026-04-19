import Foundation
import Testing

@Suite("TrayPanelMotionRegressionTests")
struct TrayPanelMotionRegressionTests {
  @Test
  func rootViewAnimatesEditorLifecycle() throws {
    let rootSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayPanelRootView.swift"), encoding: .utf8)
    let actionSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayPanelRootView+Actions.swift"), encoding: .utf8)
    let stageSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayEditorStageView.swift"), encoding: .utf8)

    #expect(actionSource.contains("withAnimation(.spring"))
    #expect(actionSource.contains("store.delete"))
    #expect(rootSource.contains("TrayEditorStageView("))
    #expect(stageSource.contains(".transition("))
    #expect(stageSource.contains(".offset(y: 20)"))
  }

  @Test
  func expandedStageKeepsTrayDockedWhileOverlayEscapesUpward() throws {
    let rootSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayPanelRootView.swift"), encoding: .utf8)
    let editorSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayEditorStageView.swift"), encoding: .utf8)
    let previewSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayPreviewStageView.swift"), encoding: .utf8)
    let sizerSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayPanelWindowSizerView.swift"), encoding: .utf8)
    let overlaySource = try String(contentsOf: sourceURL("Sources/KClip/Views/ClipEditorOverlayView.swift"), encoding: .utf8)

    #expect(rootSource.contains("ZStack(alignment: .bottom)"))
    #expect(rootSource.contains("TrayPanelWindowSizerView"))
    #expect(rootSource.contains("TrayPanelLayout.editorExpandedHeight"))
    #expect(rootSource.contains("if interaction.previewItem != nil") == false)
    #expect(rootSource.contains("TrayPanelLayout.trayContentHeight"))
    #expect(editorSource.contains("TrayPanelLayout.overlayBottomInset"))
    #expect(previewSource.contains("ZStack {"))
    #expect(previewSource.contains(".padding(.top, 6)"))
    #expect(previewSource.contains("alignment: .bottom") == false)
    #expect(sizerSource.contains("visibleFrame"))
    #expect(sizerSource.contains("min(size.height"))
    #expect(overlaySource.contains(".scrollIndicators(.hidden)"))
  }

  @Test
  func controllerWarmsLayoutBeforeShowingTray() throws {
    let source = try String(contentsOf: sourceURL("Sources/KClip/Services/TrayPanelController.swift"), encoding: .utf8)

    #expect(source.contains("layoutSubtreeIfNeeded()"))
    #expect(source.contains("displayIfNeeded()"))
  }

  private func sourceURL(_ path: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: path)
  }
}
