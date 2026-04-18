import Foundation
import Testing
@testable import KClip

@Suite("ClipboardStoreTaggingTests")
struct ClipboardStoreTaggingTests {
  @Test
  func togglesPinStateForClip() {
    let store = ClipboardStore(fileURL: tempURL())
    store.record(text: "alpha")

    store.togglePin(id: store.items[0].id)

    #expect(store.items[0].isPinned)
  }

  @Test
  func togglesManualTagsAndCanResetSuggestedTags() {
    let store = ClipboardStore(fileURL: tempURL())
    store.record(text: "plain text")
    let id = store.items[0].id

    store.toggleTag(id: id, tag: ClipTag.note)
    #expect(store.items[0].tags.contains(ClipTag.note))

    store.resetTags(id: id)
    #expect(store.items[0].tags == [ClipTag.general])
  }

  private func tempURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("json")
  }
}
