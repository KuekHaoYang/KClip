import AppKit
import Foundation
import Testing
import UniformTypeIdentifiers
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

  @Test
  func prefersActualImageFileOverFinderIconRepresentation() throws {
    let pasteboard = NSPasteboard(name: .init(UUID().uuidString))
    let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
    let fileData = try samplePNGData(size: NSSize(width: 160, height: 90))
    let fileSize = try #require(NSImage(data: fileData)?.size)
    let iconData = try #require(NSWorkspace.shared.icon(for: .png).tiffRepresentation)
    try fileData.write(to: url, options: .atomic)
    pasteboard.clearContents()
    pasteboard.setData(iconData, forType: .tiff)
    pasteboard.writeObjects([url as NSURL])

    if case .image(let captured)? = ClipboardCaptureReader.capture(from: pasteboard) {
      #expect(NSImage(data: captured)?.size == fileSize)
    } else {
      Issue.record("Expected file image data to win over Finder icon data")
    }
  }
}
