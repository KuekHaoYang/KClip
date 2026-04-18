import AppKit
import Foundation
import Testing
@testable import KClip

@Suite("ScreenshotMonitorTests")
struct ScreenshotMonitorTests {
  @Test
  @MainActor
  func scansNewScreenshotFilesWithoutClipboardCopy() throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let store = ClipboardStore(fileURL: tempURL())
    let monitor = ScreenshotMonitor(store: store, directoryURL: directory)
    let data = try samplePNGData(size: NSSize(width: 150, height: 100))
    let fileURL = directory.appending(path: "Screenshot 2026-04-18 at 1.31.00 PM.png")

    monitor.start()
    try data.write(to: fileURL, options: .atomic)
    monitor.scan()

    #expect(store.items.count == 1)
    #expect(store.items[0].isImage)
    #expect(store.items[0].sourceAppName == "Screenshot")
    monitor.stop()
  }

  private func tempURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("json")
  }
}
