import Foundation
import CoreGraphics
import Testing
@testable import KClip

@Suite("ClipboardItemTests")
struct ClipboardItemTests {
  @Test
  func decodesLegacyItemWithoutTags() throws {
    let data = """
    {"id":"00000000-0000-0000-0000-000000000001","text":"saved","capturedAt":0}
    """.data(using: .utf8)!

    let item = try JSONDecoder().decode(ClipboardItem.self, from: data)

    #expect(item.tags == [ClipTag.general])
  }

  @Test
  func canSuppressAndRestoreSuggestedTags() {
    let item = ClipboardItem(text: "https://example.com")
    let hidden = item.togglingTag(ClipTag.link)
    let restored = hidden.togglingTag(ClipTag.link)

    #expect(hidden.tags == [ClipTag.general])
    #expect(restored.tags.contains(ClipTag.link))
  }

  @Test
  func decodesSourceApplicationMetadata() throws {
    let data = """
    {"id":"00000000-0000-0000-0000-000000000001","text":"saved","capturedAt":0,"sourceAppName":"Safari","sourceBundleID":"com.apple.Safari"}
    """.data(using: .utf8)!

    let item = try JSONDecoder().decode(ClipboardItem.self, from: data)

    #expect(item.sourceAppName == "Safari")
    #expect(item.sourceBundleID == "com.apple.Safari")
  }

  @Test
  func imageItemsKeepImageTagAndNoTextPayload() throws {
    let item = ClipboardItem(imageData: try samplePNGData(), imageSize: CGSize(width: 96, height: 64))

    #expect(item.isImage)
    #expect(item.text == "Image 96×64")
    #expect(item.plainText == nil)
    #expect(item.tags == [ClipTag.general, .image])
    #expect(item.linkURL == nil)
  }
}
