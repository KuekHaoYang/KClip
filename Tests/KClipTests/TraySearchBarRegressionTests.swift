import Foundation
import Testing

@Suite("TraySearchBarRegressionTests")
struct TraySearchBarRegressionTests {
  @Test
  func searchButtonUsesTappableClosedCapsuleAndExpandedSearchState() throws {
    let source = try String(contentsOf: sourceURL, encoding: .utf8)

    #expect(source.contains(".frame(width: isPresented ? 304 : 42, height: 42"))
    #expect(source.contains(".onTapGesture"))
    #expect(source.contains("Text(resultLabel)"))
  }

  private var sourceURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "Sources/KClip/Views/TraySearchBarView.swift")
  }
}
