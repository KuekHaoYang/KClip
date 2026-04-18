import Foundation
import Testing
@testable import KClip

@Suite("CodeClipDetectionTests")
struct CodeClipDetectionTests {
  @Test
  func infersSwiftCodeAndLanguageFromPureSnippet() {
    let snippet = "import SwiftUI\nstruct Demo: View {\n  var body: some View { Text(\"Hi\") }\n}"

    #expect(ClipTag.inferredTags(for: snippet).contains(.code))
    #expect(CodeSnippet.parse(snippet)?.language == .swift)
  }

  @Test
  func treatsCommentedSnippetAsCode() {
    let snippet = "// Greets the user\nfunc greet() {\n  print(\"hi\")\n}"

    #expect(ClipTag.inferredTags(for: snippet).contains(.code))
    #expect(CodeSnippet.parse(snippet)?.language == .swift)
  }

  @Test
  func rejectsNarrativeTextWrappedAroundCode() {
    let snippet = "This function prints a greeting.\nfunc greet() {\n  print(\"hi\")\n}"

    #expect(ClipTag.inferredTags(for: snippet).contains(.code) == false)
    #expect(CodeSnippet.parse(snippet) == nil)
  }

  @Test
  func readsMarkdownFenceLanguage() {
    let snippet = "```python\nprint('hi')\n```"

    #expect(ClipTag.inferredTags(for: snippet).contains(.code))
    #expect(CodeSnippet.parse(snippet)?.language == .python)
  }

  @Test
  func infersSwiftUIViewSnippetWithPropertyWrappersAndModifiers() {
    let snippet = """
    import SwiftUI

    struct ClipEditorOverlayView: View {
      @Binding var text: String

      var body: some View {
        Text("Hello")
          .font(.system(size: 13, weight: .medium, design: .rounded))
      }
    }
    """

    #expect(ClipTag.inferredTags(for: snippet).contains(.code))
    #expect(CodeSnippet.parse(snippet)?.language == .swift)
  }

  @Test
  func editingMixedTextDropsCodeClassification() {
    let item = ClipboardItem(text: "func greet() {\n  print(\"hi\")\n}")
    let updated = item.updating(text: "This prints a greeting.\nfunc greet() {\n  print(\"hi\")\n}")

    #expect(updated.tags == [.general])
    #expect(updated.codeSnippet == nil)
  }

  @Test
  func decodingRecomputesSuggestedTagsForPlainText() throws {
    let data = """
    {
      "id":"00000000-0000-0000-0000-000000000111",
      "text":"The text below. If it is in English, translate it into Chinese.",
      "plainText":"The text below. If it is in English, translate it into Chinese.",
      "capturedAt":0,
      "suggestedTags":["code"]
    }
    """.data(using: .utf8)!

    let item = try JSONDecoder().decode(ClipboardItem.self, from: data)

    #expect(item.tags == [ClipTag.general])
    #expect(item.codeSnippet == nil)
  }
}
