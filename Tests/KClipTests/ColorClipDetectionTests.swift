import Foundation
import Testing
@testable import KClip

@Suite("ColorClipDetectionTests")
struct ColorClipDetectionTests {
  @Test
  func infersSingleHexColorClip() {
    let text = "#34C759"

    #expect(ClipTag.inferredTags(for: text).contains(.color))
    #expect(ColorSnippet.parse(text)?.samples.map(\.displayCode) == ["#34C759"])
  }

  @Test
  func infersSeparatedColorPaletteClip() {
    let text = "#34C759 #0A84FF\n#FF9F0A"

    #expect(ClipTag.inferredTags(for: text).contains(.color))
    #expect(ColorSnippet.parse(text)?.samples.count == 3)
  }

  @Test
  func rejectsNarrativeTextContainingHexColor() {
    let text = "Use #34C759 for success and keep the rest of this sentence as prose."

    #expect(ClipTag.inferredTags(for: text).contains(.color) == false)
    #expect(ColorSnippet.parse(text) == nil)
  }

  @Test
  func editingNarrativeTextDropsColorClassification() {
    let item = ClipboardItem(text: "#34C759")
    let updated = item.updating(text: "Primary accent is #34C759 for the current mock.")

    #expect(updated.tags == [.general])
    #expect(updated.colorSnippet == nil)
  }
}
