import Testing
@testable import KClip

@Suite("TrayTagFilteringTests")
struct TrayTagFilteringTests {
  private let items = [
    ClipboardItem(text: "import SwiftUI", isPinned: true),
    ClipboardItem(text: "plain"),
    ClipboardItem(text: "link", manualTags: [.link])
  ]

  @Test
  @MainActor
  func displayedTagsOnlyIncludeUsedFiltersAndKeepSelectedEmptyTag() {
    let model = TrayInteractionModel()
    #expect(model.displayedTags(from: items) == [ClipTag.pinned, .code, .link])

    model.toggleTag(.image)

    #expect(model.displayedTags(from: items) == [ClipTag.pinned, .code, .link, .image])
  }

  @Test
  @MainActor
  func visibleItemsPreserveStoredOrderInAllView() {
    let model = TrayInteractionModel()
    #expect(model.visibleItems(from: items).map(\.text) == ["import SwiftUI", "plain", "link"])
  }

  @Test
  @MainActor
  func visibleItemsKeepMixedStoredOrderWithoutPinReshuffle() {
    let model = TrayInteractionModel()
    let mixed = [
      ClipboardItem(text: "plain"),
      ClipboardItem(text: "import SwiftUI", isPinned: true),
      ClipboardItem(text: "link", manualTags: [.link])
    ]

    #expect(model.visibleItems(from: mixed).map(\.text) == ["plain", "import SwiftUI", "link"])
  }
}
