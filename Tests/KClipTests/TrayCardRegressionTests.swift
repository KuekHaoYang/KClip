import Foundation
import Testing

@Suite("TrayCardRegressionTests")
struct TrayCardRegressionTests {
  @Test
  func trayCardCapsOverflowingTextWithBottomFade() throws {
    let cardSource = try String(contentsOf: cardURL, encoding: .utf8)
    let fadeSource = try String(contentsOf: fadeURL, encoding: .utf8)

    #expect(cardSource.contains(".mask"))
    #expect(cardSource.contains(".truncationMode(.tail)") == false)
    #expect(fadeSource.contains(".init(color: .black, location: 0.0)"))
    #expect(fadeSource.contains(".init(color: .clear, location: 1.0)"))
  }

  @Test
  func trayCardPlacesTimestampInTopHeaderRow() throws {
    let source = try String(contentsOf: cardURL, encoding: .utf8)

    #expect(source.contains("headerRow"))
    #expect(source.contains("relativeClipTimestamp()"))
    #expect(source.contains("Text(item.primaryTag.title)"))
    #expect(source.contains("footerRow") == false)
  }

  @Test
  func trayCardShowsPinnedMarkAndSourceApplication() throws {
    let source = try String(contentsOf: cardURL, encoding: .utf8)

    #expect(source.contains("pin.fill"))
    #expect(source.contains("sourceRow"))
    #expect(source.contains("item.sourceAppName"))
    #expect(source.contains("Source unavailable"))
  }

  @Test
  func linkCardUsesDedicatedSnapshotBlock() throws {
    let source = try String(contentsOf: previewURL, encoding: .utf8)

    #expect(source.contains("snapshotBottomGap"))
    #expect(source.contains("footerHeight"))
    #expect(source.contains("spacing: snapshotBottomGap"))
    #expect(source.contains("snapshotBlock"))
    #expect(source.contains("snapshotHeight"))
    #expect(source.contains(".frame(height: snapshotHeight)"))
    #expect(source.contains(".frame(maxWidth: .infinity, minHeight: footerHeight, alignment: .topLeading)"))
    #expect(source.contains(".clipped()"))
    #expect(source.contains("footerBlock"))
    #expect(source.contains("preview.displayImage"))
    #expect(source.contains("chromeBar"))
  }

  private var rootURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }

  private var cardURL: URL {
    rootURL.appending(path: "Sources/KClip/Views/TrayCardView.swift")
  }

  private var fadeURL: URL {
    rootURL.appending(path: "Sources/KClip/Views/OverflowFadeView.swift")
  }

  private var previewURL: URL {
    rootURL.appending(path: "Sources/KClip/Views/LinkPreviewSummaryView.swift")
  }
}
