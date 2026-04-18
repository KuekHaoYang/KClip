import Testing
@testable import KClip

@Suite("CodeHighlightTests")
struct CodeHighlightTests {
  @Test
  func highlightsSwiftKeywordsTypesStringsAndModifiers() {
    let snippet = CodeSnippet(
      body: """
      import SwiftUI
      struct DemoView: View {
        @Binding var text: String
        Text("Hi").font(.title)
      }
      """,
      language: .swift
    )

    let runs = CodeHighlight.runs(for: snippet)

    #expect(runs.contains(where: { $0.text == "import" && $0.role == .keyword }))
    #expect(runs.contains(where: { $0.text == "SwiftUI" && $0.role == .type }))
    #expect(runs.contains(where: { $0.text == "@Binding" && $0.role == .keyword }))
    #expect(runs.contains(where: { $0.text == "\"Hi\"" && $0.role == .string }))
    #expect(runs.contains(where: { $0.text == ".font" && $0.role == .accent }))
  }
}
