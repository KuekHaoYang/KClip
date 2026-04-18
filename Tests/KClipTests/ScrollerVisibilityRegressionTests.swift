import Foundation
import Testing

@Suite("ScrollerVisibilityRegressionTests")
struct ScrollerVisibilityRegressionTests {
  @Test
  func trayInstallsLiveScrollViewSuppression() throws {
    let rootSource = try String(contentsOf: sourceURL("Sources/KClip/Views/TrayPanelRootView.swift"), encoding: .utf8)
    let suppressorSource = try String(contentsOf: sourceURL("Sources/KClip/Views/ScrollViewSuppressionView.swift"), encoding: .utf8)

    #expect(rootSource.contains("ScrollViewSuppressionView()"))
    #expect(suppressorSource.contains("hasHorizontalScroller = false"))
    #expect(suppressorSource.contains("hasVerticalScroller = false"))
    #expect(suppressorSource.contains("horizontalScroller = nil"))
    #expect(suppressorSource.contains("verticalScroller = nil"))
    #expect(suppressorSource.contains("autohidesScrollers = true"))
  }

  @Test
  func trayCachesSuppressedScrollViewAfterDiscovery() throws {
    let source = try String(contentsOf: sourceURL("Sources/KClip/Views/ScrollViewSuppressionView.swift"), encoding: .utf8)

    #expect(source.contains("makeCoordinator()"))
    #expect(source.contains("context.coordinator.scrollView"))
    #expect(source.contains("context.coordinator.scrollView = scrollView"))
  }

  private func sourceURL(_ path: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: path)
  }
}
