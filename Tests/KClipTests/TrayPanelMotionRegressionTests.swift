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
