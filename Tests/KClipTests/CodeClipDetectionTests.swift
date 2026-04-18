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
  func editingMixedTextDropsCodeClassification() {
    let item = ClipboardItem(text: "func greet() {\n  print(\"hi\")\n}")
    let updated = item.updating(text: "This prints a greeting.\nfunc greet() {\n  print(\"hi\")\n}")

    #expect(updated.tags == [.general])
    #expect(updated.codeSnippet == nil)
  }
}
