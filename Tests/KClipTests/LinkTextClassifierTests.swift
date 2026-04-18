import Foundation
import Testing
@testable import KClip

@Suite("LinkTextClassifierTests")
struct LinkTextClassifierTests {
  @Test
  func extractsSingleWebURL() {
    #expect(LinkTextClassifier.url(in: " https://example.com/docs ")?.absoluteString == "https://example.com/docs")
    #expect(ClipboardItem(text: "https://example.com/docs").linkURL?.host == "example.com")
  }

  @Test
  func rejectsMixedTextAndLink() {
    let text = "Read this first https://example.com/docs"

    #expect(LinkTextClassifier.url(in: text) == nil)
    #expect(ClipTag.inferredTags(for: text).contains(.link) == false)
  }

  @Test
  func rejectsNonWebSchemes() {
    #expect(LinkTextClassifier.url(in: "mailto:test@example.com") == nil)
  }
}
