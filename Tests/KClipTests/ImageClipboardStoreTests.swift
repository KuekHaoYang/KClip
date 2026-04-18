import Foundation
import Testing
@testable import KClip

@Suite("ImageClipboardStoreTests")
struct ImageClipboardStoreTests {
  @Test
  func recordsAndPersistsImageClips() throws {
    let url = tempURL()
    let first = ClipboardStore(fileURL: url, limit: 5)
    let data = try samplePNGData()
    first.record(imageData: data)
    try first.save()

    let second = ClipboardStore(fileURL: url, limit: 5)
    try second.load()

    #expect(second.items.count == 1)
    #expect(second.items[0].isImage)
    #expect(second.items[0].imageData == data)
    #expect(second.items[0].tags.contains(.image))
  }

  private func tempURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("json")
  }
}
