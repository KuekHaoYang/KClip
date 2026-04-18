import Foundation
import Testing

@Suite("StatusItemControllerRegressionTests")
struct StatusItemControllerRegressionTests {
  @Test
  func statusItemSupportsRightClickQuitMenu() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "Sources/KClip/Services/StatusItemController.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains(".rightMouseDown"))
    #expect(source.contains("Quit KClip"))
    #expect(source.contains("statusItem.menu = statusMenu"))
  }
}
