import Foundation
import Testing
@testable import KClip

@Suite("ClipboardStoreOrderingTests")
struct ClipboardStoreOrderingTests {
  @Test
  func newRegularClipsInsertBehindPinnedLane() {
    let store = makeStore()
    store.record(text: "one")
    store.record(text: "two")
    store.record(text: "three")
    store.togglePin(id: store.items[2].id)
    store.togglePin(id: store.items[2].id)

    store.record(text: "four")

    #expect(store.items.map(\.text) == ["one", "two", "four", "three"])
  }

  @Test
  func pastedRegularClipPromotesWithinRegularLaneOnly() {
    let store = makeStore()
    store.record(text: "one")
    store.record(text: "two")
    store.record(text: "three")
    store.togglePin(id: store.items[2].id)

    store.promoteAfterPaste(id: store.items[2].id)

    #expect(store.items.map(\.text) == ["one", "two", "three"])
  }

  @Test
  func unpinMovesClipToFrontOfRegularLane() {
    let store = makeStore()
    store.record(text: "one")
    store.record(text: "two")
    store.record(text: "three")
    store.togglePin(id: store.items[2].id)
    store.togglePin(id: store.items[2].id)

    store.togglePin(id: store.items[1].id)

    #expect(store.items.map(\.text) == ["one", "two", "three"])
  }

  @Test
  func pinnedLaneCanBeReorderedWithoutMovingRegularClips() {
    let store = seededStore()

    store.moveClip(id: store.items[0].id, to: store.items[1].id)

    #expect(store.items.map(\.text) == ["two", "one", "four", "three"])
  }

  @Test
  func regularLaneCanBeReorderedWithoutMovingPinnedClips() {
    let store = seededStore()

    store.moveClip(id: store.items[2].id, to: store.items[3].id)

    #expect(store.items.map(\.text) == ["one", "two", "three", "four"])
  }

  @Test
  func crossLaneReorderRequestsAreIgnored() {
    let store = seededStore()

    store.moveClip(id: store.items[0].id, to: store.items[2].id)

    #expect(store.items.map(\.text) == ["one", "two", "four", "three"])
  }

  private func makeStore() -> ClipboardStore {
    ClipboardStore(fileURL: tempURL())
  }

  private func seededStore() -> ClipboardStore {
    let store = makeStore()
    store.record(text: "one")
    store.record(text: "two")
    store.record(text: "three")
    store.togglePin(id: store.items[2].id)
    store.togglePin(id: store.items[2].id)
    store.record(text: "four")
    return store
  }

  private func tempURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("json")
  }
}
