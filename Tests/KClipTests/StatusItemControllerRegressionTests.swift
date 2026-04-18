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

  @Test
  func statusItemUsesCustomTemplateIcon() throws {
    let statusSource = try String(
      contentsOf: sourceURL("Sources/KClip/Services/StatusItemController.swift"),
      encoding: .utf8
    )
    let iconSource = try String(
      contentsOf: sourceURL("Sources/KClip/Support/MenuBarIcon.swift"),
      encoding: .utf8
    )

    #expect(statusSource.contains("MenuBarIcon.makeImage()"))
    #expect(statusSource.contains("imageScaling = .scaleProportionallyDown"))
    #expect(!statusSource.contains("paperclip.circle.fill"))
    #expect(iconSource.contains("image.isTemplate = true"))
    #expect(iconSource.contains("drawBackCard()"))
    #expect(iconSource.contains("drawK()"))
  }

  private func sourceURL(_ relativePath: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: relativePath)
  }
}
