import AppKit
import Foundation
import Testing
@testable import KClip

@Suite("ClipboardCaptureReaderTests")
struct ClipboardCaptureReaderTests {
  @Test
  func capturesDirectPNGDataFromPasteboard() throws {
    let pasteboard = NSPasteboard(name: .init(UUID().uuidString))
    let data = try samplePNGData()
    pasteboard.clearContents()
    pasteboard.setData(data, forType: .png)

    if case .image(let captured)? = ClipboardCaptureReader.capture(from: pasteboard) {
      #expect(captured == data)
    } else {
      Issue.record("Expected image capture from PNG pasteboard data")
    }
  }

  @Test
  func capturesImageFilesCopiedFromFinderStylePasteboard() throws {
    let pasteboard = NSPasteboard(name: .init(UUID().uuidString))
    let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
    let data = try samplePNGData()
    let size = try #require(NSImage(data: data)?.size)
    try data.write(to: url, options: .atomic)
    pasteboard.clearContents()
    pasteboard.writeObjects([url as NSURL])

    if case .image(let captured)? = ClipboardCaptureReader.capture(from: pasteboard) {
      #expect(captured.isEmpty == false)
      #expect(NSImage(data: captured)?.size == size)
    } else {
      Issue.record("Expected image capture from copied image file URL")
    }
  }
}
