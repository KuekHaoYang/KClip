import Foundation
import Testing
@testable import KClip

@Suite("ClipboardStoreTests")
struct ClipboardStoreTests {
  @Test
  func ignoresEmptyText() throws {
    let store = makeStore()
    store.record(text: "")
    #expect(store.items.isEmpty)
  }

  @Test
  func skipsConsecutiveDuplicates() throws {
    let store = makeStore()
    store.record(text: "alpha")
    store.record(text: "alpha")
    #expect(store.items.count == 1)
  }

  @Test
  func keepsNewestItemsFirst() throws {
    let store = makeStore()
    store.record(text: "alpha")
    store.record(text: "beta")
    #expect(store.items.map(\.text) == ["beta", "alpha"])
  }

  @Test
  func trimsHistoryToLimit() throws {
    let store = makeStore(limit: 2)
    store.record(text: "one")
    store.record(text: "two")
    store.record(text: "three")
    #expect(store.items.map(\.text) == ["three", "two"])
  }

  @Test
  func roundTripsPersistence() throws {
    let url = tempURL()
    let first = ClipboardStore(fileURL: url, limit: 5)
    first.record(text: "saved")
    try first.save()

    let second = ClipboardStore(fileURL: url, limit: 5)
    try second.load()

    #expect(second.items.map(\.text) == ["saved"])
  }

  @Test
  func infersCodeAndLinkTags() throws {
    let store = makeStore()
    store.record(text: "import SwiftUI\nstruct Demo {}")
    store.record(text: "https://example.com")

    #expect(store.items[0].tags.contains(.link))
    #expect(store.items[1].tags.contains(.code))
  }

  @Test
  func deletesItemByIdentifier() throws {
    let store = makeStore()
    store.record(text: "alpha")
    store.record(text: "beta")

    store.delete(id: store.items[0].id)

    #expect(store.items.map(\.text) == ["alpha"])
  }

  @Test
  func updatesItemTextAndRetagsIt() throws {
    let store = makeStore()
    store.record(text: "plain text")

    store.update(id: store.items[0].id, text: "https://example.com")

    #expect(store.items[0].text == "https://example.com")
    #expect(store.items[0].tags.contains(.link))
  }

  @Test
  func recordsSuppliedSourceApplicationMetadata() throws {
    let store = makeStore()

    store.record(text: "alpha", sourceAppName: "Safari", sourceBundleID: "com.apple.Safari")

    #expect(store.items[0].sourceAppName == "Safari")
    #expect(store.items[0].sourceBundleID == "com.apple.Safari")
  }

  private func makeStore(limit: Int = 5) -> ClipboardStore {
    ClipboardStore(fileURL: tempURL(), limit: limit)
  }

  private func tempURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("json")
  }
}
