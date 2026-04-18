import Foundation
import Testing
@testable import KClip

@Suite("TrayPasteRequestTests")
struct TrayPasteRequestTests {
  private let items = [
    ClipboardItem(text: "first", capturedAt: .distantPast),
    ClipboardItem(text: "second", capturedAt: .now)
  ]

  @Test
  @MainActor
  func secondActivationReturnsSelectedClipIdentity() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)

    let result = model.activate(index: 1, items: items)

    #expect(result == items[1])
  }

  @Test
  @MainActor
  func pasteSelectionReturnsCurrentClipIdentity() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)

    let result = model.pasteSelection(items: items)

    #expect(result == items[1])
  }

  @Test
  @MainActor
  func quickPasteReturnsSelectedClipIdentity() {
    let model = TrayInteractionModel()

    let result = model.quickPaste(commandNumber: 2, items: items)

    #expect(result == items[1])
  }

  @Test
  @MainActor
  func keyHandlingReturnsPasteRequestWithIdentity() {
    let model = TrayInteractionModel()
    _ = model.activate(index: 1, items: items)

    #expect(model.handle(.pasteSelection, items: items) == .paste(items[1]))
  }
}
