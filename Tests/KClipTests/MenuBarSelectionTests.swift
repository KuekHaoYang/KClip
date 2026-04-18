import Testing
@testable import KClip

@Suite("MenuBarSelectionTests")
struct MenuBarSelectionTests {
  @Test
  func movesWithinBounds() {
    var selection = MenuBarSelection()
    selection.move(delta: 1, itemCount: 3)
    selection.move(delta: 10, itemCount: 3)
    #expect(selection.index == 2)
  }

  @Test
  func movesUpWithoutGoingNegative() {
    var selection = MenuBarSelection(index: 2)
    selection.move(delta: -1, itemCount: 3)
    selection.move(delta: -10, itemCount: 3)
    #expect(selection.index == 0)
  }

  @Test
  func quickIndexMatchesCommandNumber() {
    let selection = MenuBarSelection(index: 0)
    #expect(selection.quickIndex(forCommandNumber: 3, itemCount: 5) == 2)
    #expect(selection.quickIndex(forCommandNumber: 9, itemCount: 5) == nil)
  }

  @Test
  func normalizesToAvailableItems() {
    var selection = MenuBarSelection(index: 4)
    selection.normalize(itemCount: 2)
    #expect(selection.index == 1)
  }
}
