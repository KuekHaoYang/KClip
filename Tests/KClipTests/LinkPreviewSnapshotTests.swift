import AppKit
import Foundation
import Testing
@testable import KClip

@Suite("LinkPreviewSnapshotTests")
struct LinkPreviewSnapshotTests {
  @Test
  func blankArtworkFallsBackToDesignedCard() {
    let preview = LinkPreviewSnapshot(url: URL(string: "https://example.com")!, title: "Example", image: solidImage(.white))

    #expect(preview.displayImage == nil)
  }

  @Test
  func detailedArtworkRemainsAvailable() {
    let preview = LinkPreviewSnapshot(url: URL(string: "https://example.com")!, title: "Example", image: stripedImage())

    #expect(preview.displayImage != nil)
  }

  private func solidImage(_ color: NSColor) -> NSImage {
    let image = NSImage(size: NSSize(width: 64, height: 64))
    image.lockFocus()
    color.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: image.size)).fill()
    image.unlockFocus()
    return image
  }

  private func stripedImage() -> NSImage {
    let image = solidImage(.white)
    image.lockFocus()
    NSColor.black.setFill()
    for offset in stride(from: 0, to: 64, by: 8) {
      NSBezierPath(rect: NSRect(x: offset, y: 0, width: 4, height: 64)).fill()
    }
    image.unlockFocus()
    return image
  }
}
