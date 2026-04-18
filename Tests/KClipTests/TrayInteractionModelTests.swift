import Foundation
import Testing
@testable import KClip

@Suite("TrayInteractionModelTests")
struct TrayInteractionModelTests {
  private let items = [
    ClipboardItem(text: "first", capturedAt: .distantPast, manualTags: [.note]),
    ClipboardItem(text: "second", capturedAt: .now, manualTags: [.code]),
  ]

  @Test
  @MainActor
  func firstActivationOnlySelects() {
    let model = TrayInteractionModel()

    let result = model.activate(index: 1, items: items)

    #expect(result == nil)
    #expect(model.selection.index == 1)
  }

  @Test
  @MainActor
  func activatingSelectedItemReturnsTextToPaste() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)

    let result = model.activate(index: 1, items: items)

    #expect(result?.text == "second")
  }

  @Test
  @MainActor
  func pasteSelectionUsesCurrentSelection() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)

    let result = model.pasteSelection(items: items)

    #expect(result?.text == "second")
  }

  @Test
  @MainActor
  func quickPasteReturnsMatchingClip() {
    let model = TrayInteractionModel()

    let result = model.quickPaste(commandNumber: 2, items: items)

    #expect(result?.text == "second")
    #expect(model.selection.index == 1)
  }

  @Test
  @MainActor
  func filtersVisibleItemsBySearchText() {
    let model = TrayInteractionModel()
    model.searchText = "sec"

    let result = model.visibleItems(from: items)

    #expect(result.map { $0.text } == ["second"])
  }

  @Test
  @MainActor
  func filtersVisibleItemsBySelectedTag() {
    let model = TrayInteractionModel()
    model.toggleTag(.code)

    let result = model.visibleItems(from: items)

    #expect(result.map { $0.text } == ["second"])
  }

  @Test
  @MainActor
  func presentingSearchClearsTagFilter() {
    let model = TrayInteractionModel()
    model.toggleTag(.code)

    model.toggleSearch()

    #expect(model.isSearchPresented)
    #expect(model.selectedTag == nil)
  }

  @Test
  @MainActor
  func selectingTagCollapsesSearchAndClearsQuery() {
    let model = TrayInteractionModel()
    model.searchText = "sec"
    model.toggleSearch()

    model.toggleTag(.note)

    #expect(model.isSearchPresented == false)
    #expect(model.searchText.isEmpty)
    #expect(model.selectedTag == .note)
  }

  @Test
  @MainActor
  func selectionScrollAnimationCanBeDisabled() {
    let model = TrayInteractionModel()

    model.setSelectionScrollAnimation(isEnabled: false)

    #expect(model.animateSelectionScroll == false)
  }
}
