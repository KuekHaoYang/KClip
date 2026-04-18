import Foundation
import Testing

@Suite("TrayShadowRegressionTests")
struct TrayShadowRegressionTests {
  @Test
  func clipTrayViewDoesNotPaintOuterShadow() throws {
    let sourceURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "Sources/KClip/Views/ClipTrayView.swift")

    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains(".shadow(") == false)
  }
}
