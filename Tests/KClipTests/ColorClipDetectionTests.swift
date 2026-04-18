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

  @Test
  func updatingSampleSkipsEquivalentColorWrite() throws {
    let snippet = try #require(ColorSnippet.parse("#0A84FF"))

    let updated = snippet.updatingSample(
      at: 0,
      red: 10.0 / 255.0,
      green: 132.0 / 255.0,
      blue: 1.0,
      alpha: 1.0
    )

    #expect(updated == nil)
  }

  @Test
  func updatingSampleRewritesOnlySelectedColor() throws {
    let snippet = try #require(ColorSnippet.parse("#0A84FF #34C759"))

    let updated = try #require(
      snippet.updatingSample(at: 1, red: 1.0, green: 159.0 / 255.0, blue: 10.0 / 255.0, alpha: 1.0)
    )

    #expect(updated == "#0A84FF #FF9F0A")
  }
}
