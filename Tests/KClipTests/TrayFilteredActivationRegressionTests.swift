import Foundation
import Testing
@testable import KClip

@Suite("TrayFilteredActivationRegressionTests")
struct TrayFilteredActivationRegressionTests {
  private let items = [
    ClipboardItem(text: "note"),
    ClipboardItem(text: "first image", imageData: Data([0x01])),
    ClipboardItem(text: "second image", imageData: Data([0x02]))
  ]

  @Test
  @MainActor
  func filteredTagViewRequiresASelectionClickBeforePaste() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 0, items: items)
    model.toggleTag(.image)
    let filtered = model.visibleItems(from: items)
    model.normalize(itemCount: filtered.count)

    let firstClick = model.activate(index: 0, items: filtered)
    let secondClick = model.activate(index: 0, items: filtered)

    #expect(filtered.map(\.text) == ["first image", "second image"])
    #expect(firstClick == nil)
    #expect(secondClick?.id == filtered[0].id)
  }
}
