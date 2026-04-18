import Foundation
import Testing

@Suite("PermissionGuideViewRegressionTests")
struct PermissionGuideViewRegressionTests {
  @Test
  func guideViewUsesAppKitFileDragSourceAndPlusFallback() throws {
    let rootURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
    let tileURL = rootURL.appending(path: "Sources/KClip/Views/PermissionDragTileView.swift")
    let dragSourceURL = rootURL.appending(path: "Sources/KClip/Views/PermissionFileDragSourceView.swift")

    let tileSource = try String(contentsOf: tileURL, encoding: .utf8)
    let dragSource = try String(contentsOf: dragSourceURL, encoding: .utf8)

    #expect(tileSource.contains("PermissionFileDragSourceView"))
    #expect(tileSource.contains(".onDrag") == false)
    #expect(tileSource.contains("click +"))
    #expect(dragSource.contains("NSViewRepresentable"))
    #expect(dragSource.contains("beginDraggingSession"))
  }

  @Test
  func guideCopyStaysMultilineInsteadOfTruncating() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "Sources/KClip/Views/PermissionGuideRootView.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains(".fixedSize(horizontal: false, vertical: true)"))
    #expect(source.contains("If the drop target refuses it"))
    #expect(source.contains("Restart KClip"))
  }

  @Test
  func guideUsesDedicatedWindowDragRegion() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "Sources/KClip/Views/PermissionGuideRootView.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains("WindowDragGesture"))
  }

  @Test
  func guidePanelDisablesGenericWindowDragging() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "Sources/KClip/Services/PermissionGuideController.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains("panel.isMovable = false"))
    #expect(source.contains("panel.isMovableByWindowBackground = false"))
  }
}
